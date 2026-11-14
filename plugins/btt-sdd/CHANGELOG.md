# Changelog do plugin btt-sdd

Registro de toda mudança que bate a versão de `plugins/btt-sdd/.claude-plugin/plugin.json`
(`docs/GIT-WORKFLOW.md`, passo 3b/3c) — não só scaffold, qualquer conteúdo empacotado (agentes,
skills, docs de governança, templates). Versão mais nova primeiro. Toda entrada nova é adicionada
no mesmo commit/PR que bate a versão, nunca depois.

**Histórico anterior a `1.22.13`**: este arquivo nasceu com um propósito mais estreito —
rastrear só `skills/create-project/scaffold/docs/*.md` e `skills/create-project/scaffold/
CLAUDE.md`, para o mecanismo `/sdd-sync-docs` (removido na versão `1.23.0`, ver a própria entrada
abaixo) comparar contra a versão instalada. Quando esse mecanismo foi removido, o arquivo passou
a ser tratado como só histórico, sem receber novas entradas — e ficou **~295 bumps de versão sem
nenhum registro** (de `1.22.12` até `1.52.12`) antes de ser reaproveitado como o changelog geral
do plugin que é hoje. As entradas de `1.22.13` a `1.52.12` abaixo foram reconstruídas em bloco a
partir do histórico real de PRs/commits deste repositório (2026-11-02) — cada uma deriva do
"Resumo" que o próprio PR já tinha, não foi redigida à mão retroativamente; a voz/estilo varia
entrada a entrada porque reflete quem escreveu aquele PR na época. Da próxima versão em diante,
toda entrada nasce no próprio PR que bate a versão (passo 3c acima), não mais reconstruída depois.

## 1.61.23 — 2026-11-14

- **`architect` descreve a ordem de execução do deploy quando uma tarefa liga comportamento por configuração persistente** (#720): novo `agents/architect/ordem-de-execucao-do-deploy.md` (ordem config → código → release → config, rollback, guarda contra release falha/rerun, premissas de plataforma não medidas com falha fechada) e linha no índice de `architect.md`.

## 1.61.22 — 2026-11-14

- **Agentes de revisão não declaram a próxima etapa; `sre` ignora passos informativos "Pulado — ..." ao julgar se a suíte rodou** (#717): `qa-engineer`, `code-reviewer` e `security-engineer` passam a escrever "roteamento da próxima etapa: ver a skill" (a cadência por fatia decide); `sre/ci-cadencia-e-custo.md` manda ler só os passos reais.

## 1.61.21 — 2026-11-14

- **Passo de integração do `code-review` renumerado de 3b para 3d** (#649): havia dois passos "3b" na skill (timing-log e integração); a numeração agora bate com a de `qa`. O resto da regra (não commitar o `timing-log.md` entre etapas, não apagar a branch do agente antes de confirmar, `cherry-pick` como fallback) já estava na `master`.

## 1.61.20 — 2026-11-13

- **Run fora do draft com passos caros `skipped` não prova a suíte, em qualquer fatia de código** (#713): `docs/gates/merge.md` estende a regra além de workflow/Docker; `sre/ci-cadencia-e-custo.md` proíbe baseline que pulou os passos caros e manda o `workflow_dispatch` ignorar o filtro; nota no passo 2d de `code-review`.

## 1.61.19 — 2026-11-13

- **`architect` lê o código do chamador de outra spec antes de afirmar que o escopo do port já vem instalado** (#712): novo `agents/architect/escopo-do-chamador-outra-spec.md` (arquivo/linha no TRD; `null` cobre ausência, não exceção) e linha no índice de `architect.md`.

## 1.61.18 — 2026-11-12

- **Correção que muda normalização/validação de campo de entrada exige testes dos valores vizinhos** (#710): `skills/implement/_rules/correcao-nao-reintroduz-defeito.md` ganha a seção com zero, vazio, máximo e colado; passo 3d aponta para ela.

## 1.61.17 — 2026-11-12

- **Checklist pré-revisão do `frontend-developer` cobre rótulo-no-nome, contraste calculado, nome de
  instâncias repetidas e mutação nos ramos novos (issue #706).**
  `agents/frontend-developer/checklist-pre-revisao.md`.

## 1.61.16 — 2026-11-12

- **Medição contra limiar é repassada com valor bruto e método (issue #707).** Passo 3a de
  `skills/{code-review,qa,security,sre}/SKILL.md`: sem arredondar, e "reconfira" a menos de 1% do
  limiar. `agents/sre.md` (passo 4b): um comentário-resumo por fatia em vez de um por issue.

## 1.61.15 — 2026-11-12

- **Teste de acesso negado (403/401) precisa de tarefa dona no TRD; sondagem de worktree herda registro
  de specs anteriores (issue #704).** Novo `agents/architect/acesso-negado-teste-dono.md`, índice do
  `architect` e item em `docs/gates/trd.md`. `skills/implement/SKILL.md` (passo 4d): consulta os
  `timing-log.md`/planos de specs anteriores antes de sondar o worktree.

## 1.61.14 — 2026-11-11

- **Sondar uma vez por spec se o worktree isolado aceita `git` (issue #702).** `skills/implement/SKILL.md`
  (passo 4d): o primeiro agente isolado roda `git status` antes da tarefa; o resultado vai para o plano e
  o `timing-log.md`, e com "recusa git" o resto da spec roda no checkout principal. As skills
  `code-review`, `qa`, `security`, `sre` e `ux-review` leem esse registro e não repetem a tentativa.

## 1.61.13 — 2026-11-11

- **Delta de infra/dev pós-code-review fica coberto pelo `sre` (issue #675).** `docs/gates/qa.md` e
  `skills/qa/SKILL.md` (passo 2a): correção só de infra/dev, sem código de aplicação, não exige nova
  rodada de code review quando o `sre` da fatia a revisa; o QA registra o SHA como "coberto pelo
  `sre`". `skills/implement/SKILL.md` (retomada, passo 2d) avisa o orquestrador.

## 1.61.12 — 2026-11-11

- **Gate de frescor do QA aceita delta provado só de comentário/texto (issue #683).** `skills/qa/SKILL.md`
  (passo 2a) e `docs/gates/qa.md`: o orquestrador prova mecanicamente que as linhas de código são
  idênticas sem os comentários e registra a prova, sem nova rodada de code review. Comentário lido por
  ferramenta, linha de código tocada ou dúvida mantêm a regra normal.

## 1.61.11 — 2026-11-11

- **Skills de revisão fixam a ref do worktree isolado e orientam o fallback quando ele bloqueia
  `git` (issue #686).** `skills/{code-review,qa,security,sre,ux-review}/SKILL.md`: a instrução ao
  agente informa branch e SHA da ponta e manda seguir `worktree-checkout.md` e confirmar o SHA.
  `skills/implement/SKILL.md`: fallback de trilhas em sequência no diretório principal, backend
  primeiro, com o custo de perder o paralelismo.

## 1.61.10 — 2026-11-11

- **Code review reaproveita o artefato de cobertura fresco para suíte e build (issue #676).**
  `agents/code-reviewer.md`, área 8: com o `Commit` do artefato batendo, não reexecuta a suíte
  completa nem o build; a reexecução integral fica com o `qa-engineer`. O reaproveitamento por
  trilha já existia em `docs/TESTING.md` e `agents/qa-engineer.md`.

## 1.61.9 — 2026-11-11

- **Pendência já registrada como decisão do usuário não é re-medida a cada fatia (issue #677).**
  `agents/sre.md`: cita a entrada existente e registra só o que mudou.

## 1.61.8 — 2026-11-11

- **Prova "falha sem a correção" limpa o cache do bundler; teste-guarda de dependência remendada
  entra no bump (issue #681).** Novo `agents/qa-engineer/prova-sem-correcao-limpa-cache.md` e
  bullet de bump de dependência remendada em `agents/sre.md`.

## 1.61.7 — 2026-11-11

- **Investigação de acesso privado mede também a resolução de `uses:` externo (issue #685).** Novo
  `agents/architect/acesso-recursos-privados.md`: a tarefa registra `[medido]` a configuração de
  acesso de Actions do repositório da ação e o resultado de um workflow de sonda que a usa.

## 1.61.6 — 2026-11-11

- **Passo de workflow que só roda fora de PR é provado por sonda descartável no runner (issue #684).**
  Novo `agents/sre/sonda-descartavel-runner.md` e `agents/security-engineer/sonda-descartavel-runner.md`:
  antes de classificar como `[inferido]`, o agente pede ao orquestrador uma branch de sonda com um
  workflow de `push` que repete os comandos do passo; o orquestrador cria e remove a branch.

## 1.61.5 — 2026-11-11

- **Gate de merge e hotfix avisam quando o filtro de paths do CD impede o deploy (issue #688).**
  `skills/hotfix/SKILL.md` ganha o passo 6c e `docs/gates/merge.md` o item equivalente: comparar o diff
  com o `paths:` do CD e pedir a autorização do `workflow_dispatch` já antes do merge.

## 1.61.4 — 2026-11-11

- **`Closes #N` das issues de tarefa conferido antes do merge (issue #687).** `skills/implement/SKILL.md`
  ganha o passo 5c (orquestrador compara `closingIssuesReferences` com a coluna "Issue GitHub" do TRD
  e completa o corpo do PR) e `docs/gates/merge.md` ganha o item equivalente antes do merge.

## 1.61.3 — 2026-11-11

- **Tracking de achados fechado na própria fatia (issue #678).** `skills/implement/SKILL.md` (retomada,
  passo 2c): o orquestrador marca a linha do achado como `corrigido na fatia, pendente de
  reverificação` no commit da correção. `docs/gates/merge.md`: item de gate novo — nenhuma linha
  `aberto` sem `corrigido`/`aceito`/`transferido` ao fechar a fatia, conferido por quem fecha.

## 1.61.2 — 2026-11-11

- **Implement: pré-requisitos externos verificados antes de despachar o agente (issues #673, #679).**
  Novo `skills/implement/_rules/pre-requisitos-externos.md`: o plano lista credenciais, permissões,
  tags/releases e ferramentas locais, o orquestrador verifica cada um com um comando barato e
  pede o que faltar no mesmo `AskUserQuestion` que aprova o plano, em vez de o agente parar em
  segundos e a espera humana correr depois.

## 1.61.1 — 2026-11-11

- **Code review: provar o run completo antes de revisar quando a fatia mexe em CI/Docker/dependência
  autenticada (issues #672, #674, #680).** `skills/code-review/SKILL.md` ganha o passo 2d: sob
  `ci-antes-do-merge`, o orquestrador tira o PR do draft, dispara o run com delta de código/infra,
  confere os passos do job e passa o id do run ao revisor; inclui o fallback de rodar no checkout
  principal quando o worktree isolado recusa `git`. `docs/gates/merge.md` registra que push só de
  `specs/` e `gh pr ready` logo após um push não provam os passos caros.

## 1.61.0 — 2026-11-06

- **TRD: ficha de contrato existente por alvo em spec de migração ou paridade (issue #664).**
  `Tipo de spec: migração/paridade` no PRD, ou `--paridade` em `/btt-sdd:trd`, aciona
  `agents/architect/ficha-contrato-existente.md`: arquivo condicional `trd/existing-contract.md`
  com uma ficha por alvo (interface, autorização, regras, efeitos colaterais, cliente atual,
  testes), evidência `[medido]`/`[inferido]`/`[não medido]` e tarefa de teste de caracterização
  antes da implementação de alvo sem teste. Arquivo novo e condicional, sem bump de formato.

## 1.60.0 — 2026-11-06

- **Rodada de perguntas ao PM como seção padrão de `tracking.md` (issue #665).** PRD e TRD ganham,
  dentro de "Decisões de produto", a subseção "Rodada de perguntas ao PM" (pergunta fechada,
  alvos afetados, opções, sugestão padrão, pendência que resolve). `product-design`/`architect`
  a geram com 5 ou mais pendências de produto abertas; `/btt-sdd:amend` resolve em lote com uma
  linha de log; `/btt-sdd:pending` lista a rodada como um item. Mudança aditiva, sem bump de
  formato. Regra em `gates/governanca.md`.

## 1.59.0 — 2026-11-06

- **`/trd`: modo de mínima mudança arquitetural (issue #667).** `--minima-mudanca` (ou `Modo
  arquitetural: mínima mudança` no cabeçalho do PRD, por spec, sem herança) ativa
  `agents/architect/minima-mudanca.md`: tabela de peças novas contra o componente existente que
  cada uma imita, alternativa conservadora por decisão nova, seção de impacto no legado, lacuna do
  PRD como decisão de produto em vez de redesenho, e arquivo a imitar em cada tarefa. Seção 3b
  condicional em `architecture.md`; `code-reviewer` trata peça fora da tabela como achado.

## 1.58.0 — 2026-11-06

- **`architect`: fase 0 de leitura crítica do PRD antes de desenhar (issue #666).** Novo arquivo-filho
  `agents/architect/readiness-do-prd.md`: lacunas classificadas em bloqueante / assumível / técnica,
  perguntas bloqueantes em lote único, premissas assumíveis na nova seção 15b "Premissas assumidas"
  de `trd/tracking.md` (aditiva, sem bump de formato) e toda decisão do TRD citando o requisito de
  origem. Gate de TRD atualizado.

## 1.57.0 — 2026-11-06

- **Pendências VALIDAR DEPOIS separadas em "Decisões de produto" e "Decisões de engenharia"
  (issue #662).** `tracking.md` de PRD, TRD e dos cinco artefatos de revisão passa a `v3`, com duas
  tabelas pelo dono da decisão; item que depende dos dois fica com quem tem a decisão final, e o
  ID não muda ao mover de tabela. Regra em `gates/governanca.md`; agentes classificam ao
  registrar; `/btt-sdd:pending` agrupa a saída (produto / engenharia / sem classificação para
  tabela única v2); sete regras novas `v2 → v3` em `skills/migrate/migrations/`. Specs em `v2`
  continuam válidas até a próxima emenda ou `/btt-sdd:migrate`.

## 1.53.9 — 2026-11-03

- **Bloqueio do classificador de modo automático: deixado explícito que cobre também comandos
  somente-leitura contra produção.** `agents/sre/cd-riscos-operacionais.md` (+ mirror no plugin),
  seção "Bloqueio do classificador de modo automático", documentava só mutação real de
  infra/geração de carga como tipicamente bloqueada. Numa rodada real de `/btt-sdd:sre`, três
  comandos somente-leitura/diagnóstico seguidos contra um app de produção real (`heroku run "php
  -v && php -m"`, duas variações, e `heroku builds --app <app>`) foram bloqueados um atrás do
  outro — nenhuma mutação. Deixado explícito que o bloqueio não distingue leitura de mutação:
  qualquer comando de CLI contra app de produção real tende a cair nele, e o plano deve antecipar
  isso para qualquer comando desse tipo, não só para mutação.
- Relatado em `specs/0007-relatorios/reviews/sre-review/F-1.md` (seção 3, TRD-3) de um projeto
  real usando este pipeline, reportado como issue #609.
- Bump de versão do plugin: `1.53.8` -> `1.53.9`.

## 1.53.8 — 2026-11-03

- **Injeção de fórmula em CSV (CWE-1236), flagueada proativamente no desenho do TRD.** Nova
  verificação em `agents/architect/padroes-de-design-especificos.md` (+ mirror no plugin): quando
  uma tarefa exporta CSV/planilha a partir de campo de texto livre do usuário, o `architect`
  documenta explicitamente o risco e a mitigação (escapar célula cujo primeiro caractere seja
  `=`/`+`/`-`/`@`/tab/CR) na seção "Riscos e trade-offs" do TRD, mesmo nível de proatividade já
  aplicado a XSS/SQL injection — em vez de só a revisão de segurança descobrir depois da
  implementação.
- Padrão observado numa fatia real de exportação de relatório em CSV, onde o achado só foi pego
  na revisão de segurança via reprodução com payload `=HYPERLINK(...)`, reportado como issue #610.
- Bump de versão do plugin: `1.53.7` -> `1.53.8`.

## 1.53.7 — 2026-11-03

- **`docs/AGENT-PREAMBLE.md`: nova seção sobre quem mede a duração de um agente retomado.**
  Agentes retomados via `SendMessage` (ex.: `frontend-developer`, `security-engineer`) relataram
  não ter como medir a própria duração quando instruídos a registrar sua linha em
  `timing-log.md` — eles não veem a notificação de conclusão da própria invocação anterior, só o
  orquestrador vê. Deixado explícito: um agente retomado escreve só a descrição do que fez, nunca
  um valor de duração; medir a duração é responsabilidade exclusiva de quem o invocou.
- Padrão observado em duas invocações reais (`frontend-developer` e `security-engineer`) na mesma
  fatia, reportado como issue #611.
- Bump de versão do plugin: `1.53.6` -> `1.53.7`.

## 1.53.6 — 2026-11-03

- **Vazamento de identificação de projeto consumidor privado, corrigido.** `sdd-sre/SKILL.md`
  (passo 5c) criava, e `repo-issues/SKILL.md` (passo d2/d3) reaproveitava/espelhava, um label
  `spec:<projeto>/<slug>` — onde `<projeto>` era o nome do repositório consumidor — em toda
  issue/PR aberta contra este repositório público a partir da retrospectiva de fatia. Isso
  publicou o nome de três projetos privados via ~32 labels reais no repositório. Removido por
  completo o mecanismo de label de origem (`sdd-sre`, `repo-issues`, root + mirror no plugin para
  `sdd-sre`); adicionada instrução explícita para nunca nomear o projeto/repositório consumidor
  no título ou corpo da issue também, mesmo princípio.
- As ~32 labels históricas (`spec:ridersbnu-app/...`, `spec:gwm-form-fill/...`,
  `spec:controle-espaco-terapias/...`) apagadas do repositório — remove automaticamente de toda
  issue/PR que as carregava.
- Este próprio `CHANGELOG.md` também citava os três nomes em ~28 entradas históricas — todas
  substituídas por identificadores genéricos (`projeto-A`/`projeto-B`/`projeto-C`), preservando o
  resto de cada relato técnico.
- Pedido direto do usuário ao notar o label `spec:controle-espaco-terapias/0017-deploy-producao`
  numa issue real (issue #607).
- Bump de versão do plugin: `1.53.5` -> `1.53.6`.

## 1.53.5 — 2026-11-03

- `/sdd-migrate` (passo 9): o texto exato do banner "migrado" era uma referência circular — o
  núcleo da skill apontava para "a regra de migração aplicável" e cada uma das 7 regras apontava
  de volta para "o núcleo da skill, passo 9" — nenhum dos dois continha o texto literal. Quem
  rodava a migração chegava ao fim da referência sem nunca encontrar o que escrever, e tinha que
  compor o próprio banner (confirmado ao vivo num projeto consumidor). Texto exato agora
  declarado uma única vez no passo 9, no formato já usado nas migrações reais deste repositório
  (`specs/0001-example-task-management/`).
- Bump de versão do plugin: `1.53.4` -> `1.53.5` (correção de documentação).

## 1.53.4 — 2026-11-03

- `/sdd-migrate` ganha verificação mecânica do passo 9 (esvaziar o corpo do arquivo legado):
  novo passo 9b roda `scripts/check-legacy-emptied.sh`/`.ps1` (bundled na própria skill) e recusa
  prosseguir para o commit se qualquer conteúdo original ainda estiver no arquivo. O passo 9
  sendo só prosa já falhou silenciosamente em produção: todas as execuções anteriores de
  `/sdd-migrate` num projeto consumidor fizeram a transformação para v2 corretamente mas nenhuma
  esvaziou o arquivo legado — 75 arquivos com ~78.700 linhas de conteúdo duplicado, só descoberto
  por auditoria manual (issue #602).
- Bump de versão do plugin: `1.53.3` -> `1.53.4` (fecha uma lacuna de verificação — tratado como
  ajuste de comportamento, não capacidade nova, já que o passo 9 já existia).

## 1.53.3 — 2026-11-03

- `code-reviewer.md`/`qa-engineer.md`: título do passo de commit corrigido de "Commite e envie
  (push) o(s) arquivo(s)/o artefato" para "Commite (nunca dê push)" — o corpo da instrução já
  dizia explicitamente para não dar push (regra de "um push por fatia",
  `docs/GIT-WORKFLOW.md`), mas o título contradizia isso, um defeito editorial que convida
  justamente ao tipo de leitura rápida/skim que causou um push indevido real relatado pelo
  usuário (issue #544).
- A regra "nunca dê push" em si já existia desde 2026-10-13 (commit `b910ab4`), antes do
  incidente relatado (2026-10-31) — a causa provável do incidente real foi um plugin desatualizado
  no projeto consumidor, não ausência da regra.
- Bump de versão do plugin: `1.53.2` -> `1.53.3` (ajuste editorial).

## 1.53.2 — 2026-11-03

- `/sdd-migrate` ganha uma salvaguarda de GitHub Flow: antes do passo 1b novo, a skill
  confirmava a branch atual mas nunca verificava se ela era a branch padrão — seguindo o passo de
  commit literalmente, uma migração rodada sem fatia ativa (ex.: migrando uma spec antiga muito
  depois de mergeada) commitaria direto em `main`/`master`, violando a regra 1 de
  `docs/GIT-WORKFLOW.md`. Agora, se a branch atual é a padrão, a skill confirma/cria uma issue e
  cria uma branch (prefixo `docs/`) antes de prosseguir; se já está no meio de outro trabalho,
  continua commitando ali, sem branch nova.
- `docs/GIT-WORKFLOW.md`, tabela "Mapeamento no pipeline SDD": nova linha para `/sdd-migrate`
  (não tinha nenhuma até agora).
- Pedido direto do usuário depois de observar a lacuna ao testar `/sdd-migrate` ao vivo a partir
  de `master` (issue #600).
- Bump de versão do plugin: `1.53.1` -> `1.53.2` (ajuste de comportamento).

## 1.53.1 — 2026-11-03

- `/sdd-migrate` deixa de manter o conteúdo completo do artefato legado após a migração: agora
  esvazia o corpo do arquivo, mantendo só o título e o banner de migração (que passa a dizer que
  o conteúdo foi *removido*, não que o arquivo é "referência histórica"). O histórico real já
  está preservado pelo Git (`git log`/`git show`); manter o conteúdo duplicado nos dois formatos
  não servia a nenhum propósito.
- Mudança aplicada às 7 regras de migração (`migrations/*.md`) e ao núcleo da skill
  (`.claude/skills/sdd-migrate/SKILL.md`, passo 9).
- Aplicada retroativamente aos 3 artefatos reais já migrados em
  `specs/0001-example-task-management/`: `prd.md`, `trd.md`, `qa-report.md`.
- Pedido direto do usuário depois de testar `/sdd-migrate` ao vivo numa spec de validação: o
  conteúdo antigo continuava inteiro no arquivo legado depois da migração, e o usuário preferiu
  que fosse removido (issue #598).
- Bump de versão do plugin: `1.53.0` -> `1.53.1` (ajuste de comportamento, não capacidade nova).

## 1.53.0 — 2026-11-02

- PRD e TRD ganham formato v2: split por tópico (núcleo `INDEX.md` + arquivos-filho lidos sob
  demanda — `docs/MICRO-CONTEXT.md`, seção 2b nova), simétrico ao split por rodada que os 5
  artefatos de revisão já tinham, mas sem rodada (PRD/TRD nascem de uma invocação só e são
  emendados via `/sdd-amend`, nunca reescritos por fatia). Cada seção mantém o número que tinha
  no arquivo único — nenhuma referência existente a "seção N do PRD/TRD" precisou mudar de
  número, só de arquivo.
- Novos templates: `specs/_template/prd/{index,user-stories,value-order,tracking}.template.md` e
  `specs/_template/trd/{index,architecture,contract,use-cases,quality,test-plan,tasks,
  tracking}.template.md`.
- Novas regras de migração `prd-v1-to-v2.md`/`trd-v1-to-v2.md` em `skills/migrate/migrations/` —
  `/sdd-migrate <slug> prd` e `/sdd-migrate <slug> trd` agora convertem de verdade (antes
  respondiam "nada para migrar" porque não existia formato v2 registrado para esses dois
  artefatos).
- `check-migration-coverage.py` generalizado para detectar split por tópico (`specs/_template/
  <artefato>/index.template.md`) além do split por rodada já suportado
  (`specs/_template/reviews/<artefato>/index.template.md`).
- Todo consumidor do pipeline atualizado para ler/escrever o formato novo, detectando legado vs.
  split (mesmo critério já usado pelos 5 artefatos de revisão): `product-design`/`sdd-prd` e
  `architect`/`sdd-trd` passam a escrever specs novas direto no formato v2; `sdd-amend`,
  `sdd-status`, `sdd-pending`, `sdd-gap-report` (scripts `.sh`/`.ps1` inclusos) e `sdd-implement`
  passam a resolver o arquivo certo em qualquer formato; `backend-developer`,
  `frontend-developer`, `code-reviewer`, `qa-engineer`, `security-engineer`, `ux-designer`, `sre`
  (+ arquivos-filho), `tech-writer` (+ arquivos-filho), `create-project` e as skills
  `sdd-code-review`/`sdd-qa`/`sdd-security`/`sdd-sre` atualizados para a mesma detecção.
- Demo de migração real: `specs/0001-example-task-management/prd.md`/`trd.md` migrados para
  `prd/`/`trd/` (mesmo espírito da demo de `qa-report` em `1.52.x`), com banner de "migrado"
  preservado nos arquivos legados.
- Pedido direto do usuário durante uma sessão de `/sdd-implement`: PRD/TRD de specs reais
  cresciam sem a mesma estrutura enxuta já aplicada aos artefatos de revisão, e `/sdd-migrate`
  não fazia nada por falta de formato v2 registrado (issue #596).
- Bump de versão do plugin: `1.52.13` -> `1.53.0` (capacidade nova, não só ajuste — split
  por tópico de PRD/TRD toca praticamente todo o conteúdo empacotado).

## 1.52.13 — 2026-11-02

- Este arquivo deixa de ser só histórico e volta a ser mantido: reescreve o cabeçalho para
  refletir seu novo papel (changelog geral do plugin, não só do scaffold de `/create-project`),
  e preenche retroativamente as ~191 entradas entre `1.22.13` e `1.52.12` que ficaram sem registro
  enquanto o mecanismo estava descontinuado — reconstruídas a partir do "Resumo" de cada PR real.
- `docs/GIT-WORKFLOW.md` (+ cópia do plugin), passo 3b: novo passo 3c — toda vez que uma mudança
  bate a versão do plugin, a entrada correspondente neste changelog é obrigatória no mesmo
  commit/PR, não um passo adiado para depois.
- Bump de versão do plugin: `1.52.12` -> `1.52.13` (toca `CHANGELOG.md` e `docs/GIT-WORKFLOW.md`
  empacotados).

## 1.52.12 — 2026-11-02

- `tech-writer` ganha duas capacidades novas: `docs/DOCS-MAP.md` (índice de navegação por spec/artefato, resolvendo legado-vs-split corretamente) e `docs/FEATURES.md` (catálogo de comportamento/features em linguagem de produto, derivado de PRD §6 + TRD §6, conferido contra código real).
- `docs/AGENT-PREAMBLE.md`, `.claude/skills/sdd-docs/SKILL.md` e `.claude/skills/sdd-sre/SKILL.md` (+ mirrors no plugin) atualizados para refletir e acionar as novas capacidades — SRE ganha o gatilho natural de atualizar o DOCS-MAP ao fechar a última fatia de uma spec.
- Validado com uma invocação real do agente `tech-writer` (worktree isolado) contra este próprio repositório: os dois arquivos gerados foram revisados linha a linha e avaliados como corretos (detecção dual-format, agrupamento coerente de critérios em comportamentos de produto, nota de escopo honesta sobre a ausência de `src/`).
- A validação real expôs uma lacuna legítima: o passo 2 de `catalogo-de-features.md` só cobria o caminho com `/sdd-gap-report` disponível. Commit de acompanhamento adiciona o fallback para `code-examples.md` + veredito do `qa-report.md` quando não há código vivo para confirmar implementação.
- Bump de versão do plugin: `1.52.11` -> `1.52.12` (conteúdo empacotado tocado por esta branch).

(PR #591)

## 1.52.11 — 2026-11-02

- A versão original desta PR entregava `/sdd-migrate-reviews`, só para os 5 artefatos de revisão. O usuário pediu, depois de ver a primeira versão: **"esse migrador precisa servir para qualquer migração de qualquer versão das documentações"** — generalizei para `/sdd-migrate <slug> <artefato>`, cobrindo qualquer artefato com template em `specs/_template/`, com detecção por marcador de versão explícito em vez de heurística estrutural sozinha (as duas decisões foram confirmadas com o usuário antes de implementar).
  - Todo template em `specs/_template/` (raiz e split por rodada) ganha `<!-- sdd-format-version: N -->` na primeira linha. Numeração **por artefato**, não global — `qa-report` pode estar em `v2` enquanto `prd` continua em `v1`. Todo artefato real gerado a partir do template herda essa linha verbatim.
  - `/sdd-migrate <slug> <artefato>` é um **núcleo genérico**: lê o marcador da instância real, compara com a versão atual do template, procura a regra de migração registrada e aplica — nunca decide a transformação por conta própria.
  - As regras específicas (antes uma tabela de referência dentro de um skill único) viram **5 arquivos** em `.claude/skills/sdd-migrate/migrations/<artefato>-v1-to-v2.md`, um por artefato de revisão (`code-review`, `qa-report`, `security-review`, `sre-review`, `ux-review`) — o núcleo não sabe transformar nenhum artefato específico, só sabe onde procurar a regra certa.
  - Artefato sem regra registrada (`prd`, `trd`, `coverage-summary`, `timing-log`) responde **"nada para migrar"**, não erro — é a infraestrutura pronta para quando esses artefatos ganharem uma `v2` no futuro, sem precisar reescrever o comando.
  - **Artefato sem marcador** (escrito antes da convenção existir) é tratado como a versão mais antiga conhecida daquele artefato, detectado estruturalmente — lacuna transitória documentada em `docs/MICRO-CONTEXT.md`, seção 3, não um erro a corrigir agora.
  - `docs/MICRO-CONTEXT.md` ganha a seção 3 (marcador de versão + registro de migrações). `docs/AGENT-PREAMBLE.md` corrige um parágrafo que ainda descrevia 4 dos 5 artefatos de revisão como "legado até migrar" — defasado desde as PRs #582-#585, que já migraram os 5.
  - Registrada 1 divergência deliberada nova em `scripts/check-plugin-sync.py` (menção a `oneshot.template.md`, que só existe na raiz).
  - Mirror completo em `plugins/btt-sdd/`.
  Fecha a issue #586 (atualizada para refletir o pivot).

(PR #587)

## 1.52.10 — 2026-11-02

- As PRs #581-#585 tocaram conteúdo empacotado em `plugins/btt-sdd/` sem incrementar `plugins/btt-sdd/.claude-plugin/plugin.json` — padrão quebrado em relação às PRs #572-#579 (sempre +1 de patch por PR tocando conteúdo empacotado).
  Bump único de catch-up: `1.52.9` → `1.52.10`.
  Closes #588

(PR #589)

## 1.52.9 — 2026-11-02

- 8ª e última PR da extensão do padrão núcleo+arquivo-filho (issue #571) — completa o lote dos 8
  agentes restantes.
  `backend-developer.md` é o maior arquivo deste lote (502 linhas), com estrutura quase idêntica a
  `frontend-developer.md` (mesmas fases, mesmos passos 5a/5b/5c/worktree) mais regras exclusivas de
  backend (SQL `GRANT`/`REVOKE`, wrapper de CLI, tradutor de erro, contenção de falha).
  - Núcleo com "Índice de regras sob demanda" (14 entradas).
  - 14 arquivos-filho cobrindo: fallback sem `AskUserQuestion`, mecânica de `Closes #N`/título de
  quebra de contrato, `run_in_background` proibido, as duas exceções de
  `coverage/<fatia>-backend.md`, reconciliação de erros pré-existentes, artefato gerado vs.
  commitado, confirmação de push, N pontos equivalentes de cobertura, dublê de captura
  real/locator estrito (issue implícita das "seis specs"), saída de worktree isolado, adapter de
  CLI com resultado vazio (caso `git describe`/`git log`), tradutor de erro com conjunto fechado,
  contenção de falha em mecanismo de alerta (`CriticalErrorReporter`), `GRANT`/`REVOKE` com escopo
  de coluna + teste de catálogo (regras 8+9 combinadas), e evidência direta vs. suposição (erro
  opaco + relato de mutação).
  - Núcleo 502 → 310 linhas; conteúdo só realocado, nada perdido.
  - Espelhado em `plugins/btt-sdd/agents/backend-developer.md` e seu diretório-filho (adaptações de
  sempre: `/sdd-X` → `/btt-sdd:X`); `plugin.json` 1.52.1 → 1.52.9 (patch — reservando 1.52.2-8
  para as PRs #572-578, ainda não mergeadas).
  `python scripts/check-plugin-sync.py` roda limpo — tanto o grupo `agents` quanto a verificação
  completa (todos os grupos).

(PR #579)

## 1.52.8 — 2026-11-02

- 7ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes.
  - Núcleo com "Índice de regras sob demanda" (13 entradas).
  - 13 arquivos-filho cobrindo: fallback sem `AskUserQuestion` (ambiguidade pontual + plano inteiro
  da Fase 1), mecânica de `Closes #N`/título de quebra de contrato, `run_in_background` proibido
  no ciclo TDD, checklist pré-revisão (createObjectURL/aria-label), as duas exceções de
  `coverage/<fatia>-frontend.md`, reconciliação de erros pré-existentes, artefato gerado vs.
  commitado (issue #449), confirmação de push contra origin, N pontos equivalentes de cobertura,
  saída de worktree isolado, autenticação e2e via API direta, grep-antes-de-concluir (issues
  #489/#497 combinadas), e evidência direta vs. suposição (erro opaco + relato de mutação).
  - Núcleo 449 → 290 linhas; conteúdo só realocado, nada perdido.
  - Espelhado em `plugins/btt-sdd/agents/frontend-developer.md` e seu diretório-filho (adaptações
  de sempre: `/sdd-X` → `/btt-sdd:X`); `plugin.json` 1.52.1 → 1.52.8 (patch — reservando 1.52.2-7
  para as PRs #572-577, ainda não mergeadas).
  `python scripts/check-plugin-sync.py` roda limpo.

(PR #578)

## 1.52.7 — 2026-11-02

- 6ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes — o maior
  arquivo deste lote (399 linhas).
  - Núcleo com "Índice de regras sob demanda" (8 entradas).
  - `security-engineer/auditoria-completa-fatia-final.md` — exceção ao fast path na última fatia.
  - `security-engineer/ci-verde-nao-prova-suite-rodou.md` — mesmo padrão já usado em outros agentes.
  - `security-engineer/worktree-checkout.md` — mecânica de checkout.
  - `security-engineer/validacao-fechada-rastreio-origem.md` — área 5, incluindo o caso real (issue
  #495).
  - `security-engineer/propagacao-controle-sem-precedente.md` — áreas 7+8 combinadas.
  - `security-engineer/medicao-sobre-leitura.md` — áreas 9+10 combinadas, incluindo o caso real
  (issue #496).
  - `security-engineer/pendencia-documentacao-nao-fecha-sozinha.md` — passos 3a/3b/3c.
  - O bloco "controle que repousa sobre premissa nunca validada" (texto quase idêntico ao já
  existente em `code-reviewer.md`) agora **aponta** para
  `code-reviewer/controle-premissa-nao-validada.md` em vez de duplicar o conteúdo — evita 2 cópias
  do mesmo texto em 2 agentes.
  - Núcleo 399 → 263 linhas; conteúdo só realocado, nada perdido.
  - Espelhado em `plugins/btt-sdd/agents/security-engineer.md` e seu diretório-filho (adaptações de
  sempre: `/sdd-X` → `/btt-sdd:X`); `plugin.json` 1.52.1 → 1.52.7 (patch — reservando 1.52.2-6
  para as PRs #572-576, ainda não mergeadas).
  `python scripts/check-plugin-sync.py` roda limpo (detectei e corrigi um over-trim acidental numa
  frase da Pré-condição durante a mirror — o diff da sync check pegou).

(PR #577)

## 1.52.6 — 2026-11-02

- 5ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes.
  - Núcleo com "Índice de regras sob demanda" (4 entradas).
  - `qa-engineer/worktree-checkout.md` — mecânica de checkout/leitura em worktree isolado, incluindo
  o caso real de leitura obsoleta na Pré-condição e os cuidados de commit/push/remoção dos passos
  8/9, combinados num só arquivo (mesmo padrão de `ux-designer/worktree-checkout.md`).
  - `qa-engineer/ci-verde-nao-prova-suite-rodou.md` — mesmo padrão já usado em
  `sre.md`/`code-reviewer.md`/`ux-designer.md`.
  - `qa-engineer/css-publicado-nao-fonte.md` — passo 2b-bis inteiro, incluindo o caso real
  (`empty:hidden`).
  - `qa-engineer/auto-avaliacao-mutacao-nao-e-evidencia.md` — passo 3c inteiro, incluindo o caso
  real das 6 mutações.
  - "Escopo de uma rodada de reverificação de achado específico" ficou **inline** no núcleo — mesmo
  precedente de `code-reviewer.md`, que mantém a seção equivalente inline por ser processo
  frequente, não um caso raro.
  - Núcleo 349 → 269 linhas; conteúdo só realocado, nada perdido.
  - Espelhado em `plugins/btt-sdd/agents/qa-engineer.md` e seu diretório-filho (adaptações de
  sempre: `/sdd-X` → `/btt-sdd:X`, `.claude/agents/X.md` → `agents/X.md`); `plugin.json` 1.52.1 →
  1.52.6 (patch — reservando 1.52.2-5 para as PRs #572-575, ainda não mergeadas).
  `python scripts/check-plugin-sync.py` roda limpo.

(PR #576)

## 1.52.5 — 2026-11-02

- 4ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes.
  - Núcleo com "Índice de regras sob demanda" (3 entradas).
  - `ux-designer/ci-verde-nao-prova-suite-rodou.md` — mesmo padrão já usado em `sre.md`/
  `code-reviewer.md`.
  - `ux-designer/verificacao-ao-vivo-jsdom.md` — a seção inteira "Verificação ao vivo em vez de só
  ler código", incluindo o caso real (`empty:hidden`/Tailwind/jsdom) que motivou a regra.
  - `ux-designer/worktree-checkout.md` — mecânica de checkout combinada com os cuidados de
  commit/push/remoção de worktree isolado (antes espalhados nos passos 6 e 7 do Processo).
  - Núcleo 336 → 265 linhas; conteúdo só realocado, nada perdido.
  - Espelhado em `plugins/btt-sdd/agents/ux-designer.md` e seu diretório-filho (adaptações de
  sempre: `/sdd-X` → `/btt-sdd:X`, `.claude/agents/X.md` → `agents/X.md`); `plugin.json` 1.52.1 →
  1.52.5 (patch — reservando 1.52.2-4 para as PRs #572/#573/#574, ainda não mergeadas).
  `python scripts/check-plugin-sync.py` roda limpo. Confirmei que a referência cruzada em
  `qa-engineer.md` para `ux-designer.md` é a nível de arquivo (não de seção), então a realocação não
  quebra nada.

(PR #575)

## 1.52.4 — 2026-11-02

- 3ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes.
  - Núcleo com "Índice de regras sob demanda" (4 entradas).
  - `product-design/quebra-de-spec-custo.md` — justificativa de custo do passo 1b.
  - `product-design/fatias-finas-custo.md` — justificativa de custo do passo 3b.
  - `product-design/askuserquestion-indisponivel.md` — fallback sem `AskUserQuestion` (passo 2).
  - `product-design/wireframe-e-ux-parecer.md` — passos 3c+3d inteiros, condicionais a feature com
  UI (não executam em toda invocação).
  - Núcleo 178 → 146 linhas; conteúdo só realocado, nada perdido.
  - Espelhado em `plugins/btt-sdd/agents/product-design.md` e seu diretório-filho (adaptações de
  sempre: `/sdd-X` → `/btt-sdd:X`); `plugin.json` 1.52.1 → 1.52.4 (patch — reservando 1.52.2/3
  para as PRs #572/#573, ainda não mergeadas).
  `python scripts/check-plugin-sync.py` roda limpo.

(PR #574)

## 1.52.3 — 2026-11-02

- 2ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes.
  `codebase-archaeologist.md` não tinha blocos de justificativa longa ("já aconteceu de verdade"),
  mas tem uma segunda responsabilidade completa (`docs/PROJECT-CONVENTIONS.md`) acionada só em
  situações específicas (`/sdd-project-conventions`, `/create-project`, ou oportunista durante
  `/sdd-baseline`) — não a cada invocação. Mesmo padrão já usado em `sre.md` para
  `docker-dev-local.md`: responsabilidade condicional inteira movida para arquivo-filho.
  - Núcleo com "Índice de regras sob demanda" (1 entrada).
  - `codebase-archaeologist/project-conventions.md` — processo completo de
  `docs/PROJECT-CONVENTIONS.md`, movido inteiro, sem perda de conteúdo.
  - Seção residual no núcleo reduzida a um parágrafo curto com pointer.
  - Espelhado em `plugins/btt-sdd/agents/codebase-archaeologist.md` e seu diretório-filho
  (adaptações de sempre: `/sdd-X` → `/btt-sdd:X`, "pipeline"/"plugin"); `plugin.json` 1.52.1 →
  1.52.3 (patch — reservando 1.52.2 para a PR #572, ainda não mergeada).
  `python scripts/check-plugin-sync.py` roda limpo (confirmado também injetando uma divergência
  deliberada no arquivo-filho do plugin para validar que o script o descobre).

(PR #573)

## 1.52.2 — 2026-11-02

- 1ª PR da extensão do padrão núcleo+arquivo-filho (issue #571) aos 8 agentes restantes, depois do
  piloto validado em `sre.md`/`architect.md`/`code-reviewer.md` (issue #565, mergeada).
  - Núcleo com "Índice de regras sob demanda" (1 entrada).
  - `tech-writer/worktree-checkout-ocupado.md` — a seção "Se a branch da fatia já estiver
  checked-out em outro worktree" (justificativa + "já aconteceu de verdade"), movida inteira, sem
  perda de conteúdo.
  - Pointer inline no passo 4 do Processo, substituindo a seção antiga.
  - Espelhado em `plugins/btt-sdd/agents/tech-writer.md` e seu diretório-filho; `plugin.json` 1.52.1
  → 1.52.2 (patch).
  `python scripts/check-plugin-sync.py` roda limpo.

(PR #572)

## 1.52.1 — 2026-11-02

- Última PR do lote de lazy-load/micro-contexto (PRs A-D já mergeadas): aplica a regra
  "ferramenta conhecida antes de verificação manual" (`docs/MICRO-CONTEXT.md`, seção 3) aos
  callouts de ferramenta em `code-reviewer`, `security-engineer` e `sre`, que antes diziam
  "Ferramenta auxiliar (opcional, nunca gate)" — fraseado que lia como "pode ignorar". Agora
  dizem "Tente a ferramenta primeiro", deixando claro que a ferramenta determinística é o
  caminho preferido quando disponível, com a verificação manual seguindo como caminho
  principal só na ausência do binário (nunca gate, sem mudança de comportamento).
  - `code-reviewer.md`: ast-grep (regra da dependência).
  - `security-engineer.md`: semgrep, gitleaks, osv-scanner.
  - `sre.md`: hadolint, checkov.
  - `docs/TOOLING.md`: cross-referência explícita para `docs/MICRO-CONTEXT.md`, seção 3.
  - `plugins/btt-sdd/` espelhado em todos os 4 arquivos acima; `plugin.json` 1.52.0 → 1.52.1
  (patch — ajuste de fraseado, nenhuma capacidade nova).
  `python scripts/check-plugin-sync.py` roda limpo ("As duas cópias estão em dia.").

(PR #570)

## 1.52.0 — 2026-11-02

- **O que muda**
  Migra o artefato `code-review.md` de arquivo único crescente para um diretório por spec:
  ```
  specs/<slug>/reviews/code-review/
  INDEX.md         — histórico de aprovações por fatia, sempre pequeno
  tracking.md       — achados + pendências VALIDAR DEPOIS + log de revisões (tabelas compactas)
  F-<N>.md          — a prosa de cada rodada, isolada (hotfix-<data>.md para correção pontual)
  ```
  Agentes/skills leem só os 2-3 arquivos que precisam (rodada vigente + penúltima) em vez de abrir
  um arquivo de milhares de linhas — ganho real sobre o padrão de leitura seletiva que já existia
  (`docs/AGENT-PREAMBLE.md`), porque agora nem os bytes das rodadas antigas são lidos.
  - Novos templates em `specs/_template/reviews/code-review/` (`index`/`tracking`/`round`). O
  template legado (`code-review.template.md`) fica marcado como formato legado — a migração não
  é retroativa para specs já em andamento.
  - `code-reviewer.md` detecta o formato (novo se `specs/<slug>/reviews/code-review/` existir,
  legado senão) e escreve no formato certo — aproveitando a edição para também aplicar o padrão
  núcleo+detalhe sob demanda das PRs anteriores (522 → 313 linhas, 5 arquivos-filho novos).
  - `scripts/sdd-status.sh`/`.ps1` e `scripts/sdd-pending.sh`/`.ps1` (bash + PowerShell) detectam e
  leem o formato novo sem perder suporte ao legado — testado manualmente com fixtures sintéticas
  dos dois formatos (aprovado/reprovado/com ressalvas/requer revalidação).
  - Corrige `docs/gates/code-review.md`, `docs/FILE-GUIDE.md`, `docs/SDD-WORKFLOW.md` e
  `sdd-code-review/SKILL.md` para o novo layout.
  - `scripts/check-plugin-sync.py`: descobre templates aninhados via `rglob` (faltava cobrir
  `specs/_template/reviews/`) e registra `MICRO-CONTEXT` na lista de docs canônicos do pipeline
  (lacuna da PR anterior #566, só visível agora que um template referenciou o doc).
- **Por quê**
  Quarta PR da série piloto (issue de acompanhamento #565). Único tipo de artefato migrado é
  `code-review` (o que mais acumula rodadas — roda a cada fatia, nunca só ao final da spec);
  `qa-report`, `security-review` e `sre-review` ficam para rodadas futuras usando a mesma receita.
  Versão do plugin incrementada (minor, `1.52.0` — capacidade nova).
  Refs #565

(PR #569)

## 1.51.2 — 2026-11-02

- **O que muda**
  Replica o padrão validado nas duas PRs anteriores (`sre.md` #566, `architect.md` #567) na maior
  skill do pipeline: **575 → 240 linhas** no núcleo, com o detalhe elaborado movido para 10
  arquivos-filho em `.claude/skills/sdd-implement/_rules/`:
  - `retomada-nuances-e-riscos.md`
  - `dosagem-validacao-correcao.md`
  - `correcao-nao-reintroduz-defeito.md`
  - `reconciliacao-contrato-trilhas-paralelas.md`
  - `fatia-final-bookkeeping.md`
  - `fatia-sem-trabalho-pendente.md`
  - `plano-implementacao-detalhe.md`
  - `fallback-plano-texto-puro.md`
  - `troca-de-provedor.md`
  - `validacao-pos-merge-pendencias.md`
  Cada um com gatilho objetivo listado no índice do núcleo. Corrige também referências cruzadas em
  `docs/GIT-WORKFLOW.md`, `docs/MODEL-TIERING.md`, `docs/POST-MERGE-VALIDATION.md`,
  `docs/gates/implementacao.md` e nas quatro skills de revisão (`sdd-code-review`, `sdd-qa`,
  `sdd-security`, `sdd-ux-review`) que apontavam para passos de `sdd-implement/SKILL.md` que
  migraram para arquivos-filho.
- **Por quê**
  Terceira PR da série piloto (issue de acompanhamento #565) — depende da convenção de
  `docs/MICRO-CONTEXT.md` e da extensão de `scripts/check-plugin-sync.py`, já mergeadas na PR #566.
  Versão do plugin incrementada (patch, `1.51.2`).
  Refs #565

(PR #568)

## 1.51.1 — 2026-11-02

- **O que muda**
  Replica em `architect.md` o padrão validado na PR anterior (`sre.md`, #566): **615 → 298 linhas**
  no núcleo, com o detalhe elaborado movido para 6 arquivos-filho em `.claude/agents/architect/`:
  - `contrato-externo-nao-observado.md`
  - `automacao-navegador-premissa-manual.md`
  - `padroes-de-design-especificos.md` (isolamento de teste com estado, guard de autorização por
  contexto, citar precedente sem reler código, enum removido de dados persistidos, schema externo
  sem fonte interna)
  - `decomposicao-tarefas-detalhe.md`
  - `plano-de-testes-detalhe.md`
  - `riscos-trade-offs-medicao.md`
  Cada um com gatilho objetivo listado no índice do núcleo. Corrige também referências cruzadas em
  `docs/gates/trd.md`, `docs/TESTING.md` e `docs/AGENT-PREAMBLE.md` que apontavam para passos de
  `architect.md` que migraram para arquivos-filho.
- **Por quê**
  Segunda PR da série piloto (issue de acompanhamento #565) — depende da convenção de
  `docs/MICRO-CONTEXT.md` e da extensão de `scripts/check-plugin-sync.py`, já mergeadas na PR #566.
  Versão do plugin incrementada (patch, `1.51.1`).
  Refs #565

(PR #567)

## 1.51.0 — 2026-11-01

- **O que muda**
  Adiciona `docs/MICRO-CONTEXT.md`, documentando três convenções relacionadas:
  1. **Núcleo + arquivo-filho lido sob demanda** (agentes/skills): um núcleo pequeno sempre
  carregado, com um "Índice de regras sob demanda" apontando para arquivos-filho por tópico —
  lidos via `Read` só quando a tarefa bate no gatilho objetivo descrito.
  2. **Split físico por rodada** (artefatos gerados em projetos consumidores): generaliza, como
  convenção, o padrão que a PR D (próxima desta série) vai implementar em `code-review` —
  `specs/<slug>/reviews/<área>/` com `INDEX.md`/`tracking.md`/`F-<N>.md` por rodada, formato
  legado de arquivo único continua suportado para o que não migrou.
  3. **Ferramenta conhecida antes de verificação manual** (`docs/TOOLING.md`), sem criar gate novo.
  **Piloto completo em `sre.md`**: 769 → 283 linhas no núcleo, com o detalhe elaborado (justificativas,
  "já aconteceu de verdade", receitas condicionais) movido para 9 arquivos-filho em
  `.claude/agents/sre/`, cada um com gatilho objetivo listado no índice. Nenhum conteúdo foi
  perdido — núcleo + filhos somam 770 linhas, praticamente igual ao original (769).
  `scripts/check-plugin-sync.py` estendido para descobrir arquivos-filho via `rglob` (antes só
  casava arquivos planos em `.claude/agents/*.md`/`.claude/skills/*/SKILL.md`). Corrigidas também as
  referências cruzadas de outros docs/agentes que apontavam para seções de `sre.md` que migraram
  para arquivos-filho (`docs/TESTING.md`, `docs/CI-WORKFLOW.md`, `docs/FILE-GUIDE.md`,
  `docs/gates/sre.md`, `codebase-archaeologist.md`).
- **Por quê**
  Pedido do usuário: simplificar os arquivos deste plugin e os artefatos que ele gera, para que
  agentes carreguem contexto em lazy-load — cada arquivo pequeno, carregando um micro contexto.
  Investigação mostrou que artefatos gerados já tinham um padrão deliberado de leitura seletiva
  (`docs/AGENT-PREAMBLE.md`), mas arquivos-fonte (agentes/skills) não tinham split nenhum — o
  arquivo inteiro é injetado como prompt a cada invocação.
- **Escopo desta rodada (piloto, não sweep completo)**
  Esta é a primeira de uma série de PRs (issue de acompanhamento #565) — checkpoint antes de
  replicar o padrão para `architect.md`, `.claude/skills/sdd-implement/SKILL.md`, e o split físico
  de artefatos de `code-review`. Pausarei após esta PR para revisão antes de continuar.
  Versão do plugin incrementada (minor, `1.51.0` — introduz capacidade nova, não só ajuste).
  Refs #565

(PR #566)

## 1.50.10 — 2026-11-01

- **O que muda**
  Adiciona a `.claude/skills/sdd-implement/SKILL.md` (e à cópia em `plugins/btt-sdd/skills/
  implement/SKILL.md`), seção "Troca de provedor/serviço externo descoberta durante a
  implementação": a invocação ad-hoc do `architect` passa sempre `isolation: "worktree"`.
- **Por quê**
  Issue #545: essa invocação edita arquivos compartilhados (`trd.md`, `docs/STACK.md`, ADRs) sem o
  isolamento que etapas de revisão já usam por padrão (`docs/GIT-WORKFLOW.md`). Numa spec
  consumidora do plugin, uma invocação do `architect` sem isolamento ainda estava editando esses
  arquivos quando o usuário reconsiderou a decisão em andamento, exigindo uma terceira invocação de
  reversão concorrente com a segunda e um `TaskStop` no meio de uma edição para evitar corrupção.
  Versão do plugin incrementada (patch).
  Closes #545

(PR #564)

## 1.50.9 — 2026-11-01

- **O que muda**
  Torna incondicional, em `docs/GIT-WORKFLOW.md` e em `.claude/agents/code-reviewer.md`/
  `qa-engineer.md`/`sre.md` (e às cópias correspondentes em `plugins/btt-sdd/`), a instrução de usar
  branch temporária em working tree isolado: antes, o texto dizia "o `checkout` direto vai falhar,
  vá para o workaround"; agora diz "nunca tente o `checkout` direto, mesmo quando funcionaria".
- **Por quê**
  Issue #546: três agentes de revisão em sequência (`code-reviewer`, `qa-engineer`, `sre`), cada um
  isolado, conseguiram `checkout` direto da branch real da fatia porque nenhum outro worktree a
  tinha aberta naquele instante. Funcionou sem dano nas três vezes, mas é uma condição de corrida
  favorável, não uma garantia — numa fatia com trilhas em paralelo, ou com o orquestrador tocando a
  branch principal ao mesmo tempo, o mesmo `checkout` colidiria. Custou ao orquestrador trabalho
  evitável (detach + remove + checkout) nas três ocasiões.
  Versão do plugin incrementada (patch).
  Closes #546

(PR #563)

## 1.50.8 — 2026-11-01

- **O que muda**
  Adiciona um item novo (5) à convenção de `docs/TOOLING.md` e um ponteiro curto em
  `.claude/agents/backend-developer.md`, `frontend-developer.md`, `code-reviewer.md`,
  `qa-engineer.md` e `sre.md` (e às cópias correspondentes em `plugins/btt-sdd/`): antes de registrar
  um achado de "ferramenta de build/lint/teste quebrada", reexecutar vendo a saída real e
  não-filtrada.
- **Por quê**
  Issue #547: numa spec consumidora do plugin, dois agentes independentes concluíram, cada um por
  conta própria, que `npm run lint` estava quebrado em toda a codebase — o lint na verdade passava
  limpo, e a mensagem de erro confusa vinha da camada de condensação de saída do harness (que tenta
  interpretar saída vazia como JSON e falha). O achado falso se propagou por 5-6 artefatos antes de
  ser refutado por quem mediu a saída direta. Este repositório usa `rtk` para condensar saída de
  shell (`docs/TOOLING.md`) — exatamente o tipo de camada que pode produzir esse sintoma.
  Versão do plugin incrementada (patch).
  Closes #547

(PR #562)

## 1.50.7 — 2026-11-01

- **O que muda**
  Adiciona "controle de acesso em nível de infraestrutura/banco de dados (GRANT/REVOKE de
  papel/role, política de RLS, IAM/policy de nuvem)" ao critério objetivo único de
  `docs/gates/seguranca.md`, refletindo também no resumo inline de `.claude/skills/sdd-hotfix/
  SKILL.md` (passo 5) e na coluna "Validação na fatia" de `.claude/agents/architect.md` — e nas
  cópias correspondentes em `plugins/btt-sdd/`.
- **Por quê**
  Issue #548: um hotfix que concedia `GRANT UPDATE` num papel de banco de dados não se encaixava
  literalmente em nenhum item do critério objetivo existente (autenticação/autorização/sessão/dados
  pessoais/ponto de entrada externo), apesar de ser inegavelmente controle de acesso. O
  `qa-engineer` teve que sinalizar a ambiguidade no relatório em vez de decidir, e o orquestrador
  precisou perguntar ao usuário via `AskUserQuestion` "por prudência". `docs/gates/seguranca.md` é a
  fonte única citada pelos dois gatilhos (hotfix e coluna de validação de fatia), então um só ponto
  de edição resolve a ambiguidade nos dois lugares.
  Versão do plugin incrementada (patch).
  Closes #548

(PR #561)

## 1.50.6 — 2026-11-01

- **O que muda**
  Adiciona a `.claude/agents/backend-developer.md` (e à cópia em `plugins/btt-sdd/agents/
  backend-developer.md`) uma nova regra inegociável (#9): toda migração que faz `GRANT`/`REVOKE` de
  privilégio inclui uma asserção de catálogo (`has_column_privilege`/`has_table_privilege` no
  Postgres, ou equivalente) cobrindo `up()` e `down()`, não só um teste de comportamento.
- **Por quê**
  Issue #549: um teste de comportamento ("a operação de negócio volta a funcionar") não distingue um
  `GRANT` largo de um `GRANT` escopado — os dois fazem a operação passar igualmente. Numa spec
  consumidora do plugin, a primeira versão de uma migração tinha teste de integração provando o
  comportamento certo e ainda assim foi reprovada por medição independente do revisor, porque nem
  `up()` nem `down()` tinham o teste de catálogo que provaria o escopo. Complementa #550 (já
  mergeada em #559), que documentou o padrão de escopo de coluna; esta issue exige a prova via
  catálogo.
  Versão do plugin incrementada (patch).
  Closes #549

(PR #560)

## 1.50.5 — 2026-11-01

- **O que muda**
  Adiciona a `.claude/agents/backend-developer.md` (e à cópia em `plugins/btt-sdd/agents/
  backend-developer.md`) uma nova regra inegociável (#8): migração que faz `GRANT`/`REVOKE` de
  privilégio no Postgres sempre escopa à(s) coluna(s) exatas, nunca à tabela inteira.
- **Por quê**
  Issue #550: `grant update on <tabela> to <papel>` sem lista de colunas concede `UPDATE` em todas
  as colunas, reabrindo qualquer coluna bloqueada por uma migração anterior como defesa em
  profundidade além de RLS. O efeito é simétrico e mais perigoso no `down()`: `revoke update on
  <tabela> from <papel>` remove todos os `GRANT`s de `UPDATE` do papel na tabela, inclusive os de
  migrações anteriores não relacionadas — um rollback real quebraria funcionalidade de produção sem
  relação com a migração atual.
  Versão do plugin incrementada (patch).
  Closes #550

(PR #559)

## 1.50.4 — 2026-11-01

- **O que muda**
  Adiciona a `.claude/agents/backend-developer.md` (e à cópia em `plugins/btt-sdd/agents/
  backend-developer.md`) uma nova regra inegociável (#7): quando um port/adapter declara
  explicitamente (comentário ou TRD) uma invariante de "não deve propagar exceção própria", o teste
  que força essa falha internamente e confirma que o caminho chamador continua intacto passa a ser
  obrigatório antes de considerar a tarefa pronta para revisão.
- **Por quê**
  Issue #551: um `CriticalErrorReporter` testou "erro dispara alerta" e "throttle suprime repetição",
  mas nenhum teste cobria a falha do próprio throttle — se o cache ficasse indisponível, a exceção
  nova escapava do pipeline de tratamento, mascarando a exceção original por completo. Só foi pego
  na revisão de código. Complementa #552 (já mergeada em #557), que documentou o padrão
  arquitetural em `docs/ARCHITECTURE.md`; esta issue torna o teste obrigatório no TDD do
  `backend-developer`.
  Versão do plugin incrementada (patch).
  Closes #551

(PR #558)

## 1.50.3 — 2026-11-01

- **O que muda**
  Adiciona a `docs/ARCHITECTURE.md` (e à cópia em `plugins/btt-sdd/docs/ARCHITECTURE.md`) uma seção
  nova sobre contenção de falha em mecanismos que reagem a falha (log, alerta de erro crítico,
  notificação de incidente), com contra-exemplo e exemplo corrigido.
- **Por quê**
  Issue #552: mecanismos de alerta têm uma propriedade estrutural fácil de esquecer — a própria
  dependência do mecanismo (cache, banco, fila) costuma estar degradada exatamente no mesmo
  incidente que ele deveria reportar. A seção registra o padrão de contenção em duas camadas
  ortogonais (ponto de entrada + cada adapter de saída) como referência para `architect` desenhando
  um mecanismo parecido no TRD. A issue irmã #551 (próxima desta rodada) torna isso acionável como
  regra de TDD em `backend-developer.md`.
  Versão do plugin incrementada (patch).
  Closes #552

(PR #557)

## 1.50.2 — 2026-11-01

- **O que muda**
  Adiciona à área "Ports & Adapters/DI" de `.claude/agents/code-reviewer.md` (e à cópia em
  `plugins/btt-sdd/agents/code-reviewer.md`) um checklist explícito: quando o diff reaproveita um
  binding de uma interface genérica já existente, perguntar se o próprio framework (ou outra parte
  da aplicação) também depende desse mesmo binding para algum comportamento padrão/fallback, e
  exigir teste de integração que dispare esse comportamento padrão antes de aprovar.
- **Por quê**
  Issue #553: numa spec consumidora do plugin, um binding de `LoggerInterface` reaproveitado colidiu
  com o fallback de log de exceção do próprio Laravel, e quatro revisões (incluindo code review)
  aprovaram sem pegar isso — nenhuma perguntou se o binding reaproveitado tinha outro consumidor.
  Complementa a issue #554 (já mergeada em #555), que documentou o padrão geral em
  `docs/TESTING.md`; esta issue torna o checklist do `code-reviewer` acionável.
  Versão do plugin incrementada (patch).
  Closes #553

(PR #556)

## 1.50.1 — 2026-11-01

- **O que muda**
  Adiciona a `docs/TESTING.md` (e à cópia sincronizada em `plugins/btt-sdd/docs/TESTING.md`) uma
  seção nova: peças isoladas passando em verde não provam que o comportamento de ponta a ponta é o
  esperado, quando a feature reaproveita um binding/adapter genérico que o próprio framework também
  resolve para algum caminho padrão.
- **Por quê**
  Issue #554: numa spec consumidora do plugin, um binding de `LoggerInterface` reaproveitado para
  um alerta de erro crítico colidiu, em silêncio, com o fallback de log que o próprio Laravel já
  usava para toda exceção reportada — toda exceção em produção passou a logar em formato errado.
  Quatro revisões independentes (code review, QA, segurança, SRE) aprovaram a fatia sem pegar isso,
  porque cada uma testou uma peça isolada; só a primeira exceção real passando pelo pipeline
  completo revelou a divergência.
  Versão do plugin incrementada (patch) por tocar `plugins/btt-sdd/docs/TESTING.md`.
  Closes #554

(PR #555)

## 1.50.0 — 2026-10-30

- `architect.md`: nova regra em "Governança de decisão" — se precisar do parecer de outro agente do pipeline (ex. `security-engineer`) e não tiver Agent tool disponível para despachá-lo, registra um bloco estruturado `## DESPACHO NECESSÁRIO` (Agente/Motivo/Contexto a passar) no resumo final em texto puro, e marca o trecho do artefato (ex. ADR) explicitamente como "pendente do parecer de `<agente>`" — nunca um placeholder genérico.
- `sdd-trd/SKILL.md` (passo 3b-bis): orquestrador detecta o bloco e aciona o agente indicado na mesma rodada, repassando o parecer de volta ao `architect` antes de considerar o TRD pronto.
- `sdd-implement/SKILL.md` (seção "Troca de provedor/serviço externo"): mesma detecção, para quando `architect` é acionado ad-hoc em modo assíncrono/isolado durante a implementação.
- Mesmo espírito do protocolo já existente para perguntas ao usuário sem `AskUserQuestion` (VALIDAR DEPOIS devolvido em texto puro, já documentado para `architect`/`sre`) — generalizado para despacho de agente em vez de decisão do usuário.
- Replicado em `plugins/btt-sdd/`, confirmado com `python scripts/check-plugin-sync.py`.
- Bump de versão do plugin: `1.49.0` → `1.50.0` (minor, capacidade nova).

(PR #543)

## 1.49.0 — 2026-10-30

- `docs/TOOLING.md`: novo protocolo "Ao detectar uma ferramenta ausente, avise e ofereça instalar" — uma checagem de disponibilidade por rodada (nunca por área), uma pergunta via `AskUserQuestion` (`multiSelect`, uma opção por ferramenta ausente + "nenhuma"), instalação aceita confirmada antes de usar, fallback manual sem travar a etapa em nenhum caso (aceito-e-falhou, recusado, ou nenhuma ferramenta faltando).
- `security-engineer.md` (gitleaks/semgrep/osv-scanner), `sre.md` (hadolint/checkov), `code-reviewer.md` (ast-grep): aplicam o protocolo, cada um apontando para `docs/TOOLING.md` em vez de repetir a explicação completa.
- Instalação bloqueada pelo classificador de segurança do modo automático → sugere o prefixo `!` (mesmo padrão já usado em `sre.md` para mutação real de infra), nunca insiste numa 2ª tentativa.
- Replicado em `plugins/btt-sdd/`, confirmado com `python scripts/check-plugin-sync.py`.
- Bump de versão do plugin: `1.48.1` → `1.49.0` (minor, capacidade nova).

(PR #541)

## 1.48.1 — 2026-10-30

- `docs/GIT-WORKFLOW.md` (seção "Isolamento de arquivos não é isolamento de serviços com estado"): novo parágrafo distinguindo *staleness* num checkout de longa duração de *corrupção por concorrência* entre worktrees (já documentada na seção).
- Generaliza o relato da issue (removido nome de projeto/comando específico): volume Postgres antigo, reaproveitado por um checkout de longa duração, pode não ter recebido um efeito de inicialização que só roda em volume vazio (ex.: `CREATE EXTENSION`) — uma migração que depende disso falha por permissão, não por migração ausente, o que confunde o diagnóstico.
- Remédio recomendado: recriar o volume do zero antes de migrar num checkout de longa duração, em vez de só aplicar o efeito manualmente (isso é paliativo, não correção).
- Replicado em `plugins/btt-sdd/docs/GIT-WORKFLOW.md`, confirmado com `python scripts/check-plugin-sync.py`.
- Bump de versão do plugin: `1.48.0` → `1.48.1` (patch — documentação/lição, não capacidade nova).
Closes #491

(PR #539)

## 1.48.0 — 2026-10-30

- `code-reviewer.md`: nova seção "Fast path por área", escopada só às áreas 6 (Contrato Frontend↔Backend), 8 (Débito técnico) e 9 (Build/empacotamento) — para uma dessas áreas cuja superfície o `git diff --stat` da fatia claramente não toca, o veredito é uma linha citando o diff, em vez de "não aplicável" sem evidência.
- **As áreas estruturais (2 Ports & Adapters, 3 SOLID, 4 Clean code, 5 Qualidade dos testes, 7 Tratamento de erros) nunca entram no fast path** — exigem leitura arquivo por arquivo todo round, sem exceção, porque qualquer diff de código as toca.
- `code-review.template.md`: coluna `Profundidade` na tabela "Histórico de aprovações por fatia" (`completo`/`fast-path`), preenchida no passo 6 do processo.
- **Sem a complexidade de `security-engineer`/`sre`** (coluna `Commit`, recálculo de base através de rodadas fast-pathed, auditoria completa obrigatória na fatia final): o diff do `code-reviewer` já é sempre a fatia atual inteira contra `main` (nunca um recorte acumulado entre rodadas), então não há superfície pulada que precise ser recuperada depois — essa máquina adicional resolveria um problema que este agente não tem.
- Replicado em `plugins/btt-sdd/` (agente + `skills/create-project/scaffold/specs/_template/`), confirmado com `python scripts/check-plugin-sync.py`.
- Bump de versão do plugin: `1.46.0` → `1.47.0` (minor, capacidade nova).

(PR #538)

## 1.47.0 — 2026-10-30

- `docs/AGENT-PREAMBLE.md` (seção "Artefato in-place que acumulou rodadas"): estende a regra de leitura sob demanda — já aplicada à tabela "Histórico de aprovações por fatia" — para as tabelas de Achados/Pendências, a que de fato cresce mais rápido (um achado por área por rodada).
- `specs/_template/code-review.template.md`, `qa-report.template.md`, `security-review.template.md`: tabela de Achados ganha colunas `Fatia` e `Status` (`aberto`/`corrigido`/`aceito como ressalva`).
- `specs/_template/sre-review.template.md`: tabela de Pendências (seção 7, até então sem instrução explícita de uso em `sre.md`) ganha as mesmas colunas (`aberto`/`resolvido`).
- `code-reviewer.md`, `qa-engineer.md`, `security-engineer.md`, `sre.md`: instrução para preencher `Fatia`+`Status = aberto` ao registrar um achado novo, e atualizar `Status` (nunca apagar/duplicar a linha) ao confirmar uma correção numa reverificação.
- Replicado em `plugins/btt-sdd/` (docs + agentes + `skills/create-project/scaffold/specs/_template/`), confirmado com `python scripts/check-plugin-sync.py`.
- Bump de versão do plugin: `1.46.0` → `1.47.0` (minor, capacidade nova).

(PR #536)

## 1.46.0 — 2026-10-30

- Adiciona `docs/TOOLING.md` (seção "Ferramentas de análise estática e segurança"): `gitleaks`, `semgrep`, `osv-scanner` (security-engineer), `hadolint`, `checkov` (sre), `ast-grep` (code-reviewer) — mesma convenção do `rtk` já existente: recomendação, nunca gate.
- Referencia cada ferramenta na área correspondente do agente que a usa, com instrução de uso opcional + fallback manual explícito.
- Script de diagnóstico por ferramenta em `scripts/check-<ferramenta>.py`, seguindo o padrão de `scripts/check-rtk.py` (nunca distribuído com o plugin, mesmo padrão do rtk).
- Replica tudo em `plugins/btt-sdd/` (docs + agentes) e confirma com `python scripts/check-plugin-sync.py` (as duas cópias estão em dia).
- Bump de versão do plugin: `1.45.46` → `1.46.0` (minor, capacidade nova).

(PR #534)

## 1.45.46 — 2026-10-30

- **O que mudou**
  Em `docs/TESTING.md` (+ cópia do plugin), nova subseção "Armadilha
  conhecida" (mesmo padrão já usado para outros gotchas de ambiente): um
  roteiro e2e via browser automation que precisa esperar relógio real por
  mais de ~1h tende a crashar o processo do Chromium antes do próximo passo
  começar. Documenta a estratégia que funciona: dividir em múltiplas
  invocações do Playwright, persistindo estado em disco entre elas.
  Bati a versão do plugin (`1.45.45` → `1.45.46`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Caso real: duas rodadas seguidas de um roteiro que precisava esperar uma
  regra de negócio real (sem mock de `Clock` disponível) crasharam antes do
  teste seguinte começar — ~8h de relógio de parede, boa parte gasta
  redescobrindo o limite por tentativa e erro antes de chegar na estratégia
  de duas invocações separadas.
  Closes #529

(PR #532)

## 1.45.45 — 2026-10-30

- **O que mudou**
  Em `.claude/skills/sdd-code-review/SKILL.md` (novo passo 2c, + cópia do
  plugin): antes de invocar `code-reviewer`, a skill reconfirma — lendo a
  seção 13 do TRD no estado atual — se esta é a última fatia pendente da
  spec e, se for e o projeto documentar um mecanismo de sinalização ao CI,
  confirma/aplica o sinal **antes** de invocar o agente.
  Bati a versão do plugin (`1.45.44` → `1.45.45`, patch) por tocar
  `plugins/btt-sdd/skills/`.
- **Por quê**
  `/sdd-implement`, passo 2b-quater (issue #473, já corrigido), aplica esse
  sinal uma vez, quando o PR abre. Mas se uma tarefa for acrescentada à
  fatia depois disso (ex.: um roteiro e2e retroativo que o próprio
  `code-reviewer` notaria como lacuna na própria rodada), o sinal nunca é
  reverificado. Caso real: 3ª ocorrência confirmada do mesmo padrão — o
  `code-reviewer` notou a lacuna de e2e na própria rodada, mas o sinal só
  foi aplicado depois dela já ter revisado a fatia inteira sem o job real
  ter rodado.
  Closes #528

(PR #531)

## 1.45.44 — 2026-10-30

- **O que mudou**
  Em `docs/AGENT-PREAMBLE.md` (+ cópia do plugin), logo após a regra de citar
  convenções de projeto (issue #499): antes de repetir "mecanismo X já
  existe desde a spec Y, inalterado" para evitar reverificação redundante,
  confirmar se alguma migração de stack/framework/linguagem aconteceu desde
  a spec Y (`grep` em `docs/adr/`). Se houver, a citação exige reverificação
  por leitura direta do código atual, nunca repetição verbatim.
  Bati a versão do plugin (`1.45.43` → `1.45.44`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Caso real: um mecanismo de log estruturado por requisição, implementado
  na stack original, nunca foi portado numa migração de linguagem/framework
  que não mencionou observabilidade em nenhuma linha. Quatro rodadas de SRE
  consecutivas, em quatro specs diferentes já na stack nova, afirmaram que
  ele "já existia desde a spec original, inalterado" — cada rodada tornando
  a descrição mais específica que a anterior, sem nenhuma verificar contra
  o código real. Só a quinta rodada verificou e descobriu que o mecanismo
  nunca existiu na stack nova.
  Closes #527

(PR #530)

## 1.45.43 — 2026-10-30

- **O que mudou**
  Em `docs/GIT-WORKFLOW.md` (+ cópia do plugin), logo depois da seção
  "Sincronizar a branch da fatia com `main`", e em
  `.claude/skills/sdd-implement/SKILL.md` (novo item 3a-ter, + cópia do
  plugin): generaliza o gatilho de sincronização — não é mais "estou
  invocando uma das 4 skills de revisão", é "estou prestes a confiar num
  resultado de CI desta fatia". Antes de interpretar um CI vermelho/verde
  como definitivo, em qualquer ponto do ciclo de correção, confirmar
  sincronia com `origin/main` primeiro (`git merge-base --is-ancestor`).
  Bati a versão do plugin (`1.45.42` → `1.45.43`, patch) por tocar
  `plugins/btt-sdd/docs/` e `plugins/btt-sdd/skills/`.
- **Por quê**
  O gate já existia, mas só disparava dentro das 4 skills de revisão (passo
  2b de cada uma). Correção pontual conduzida diretamente via
  `/sdd-implement`, fora dessas skills, não passava por ele. Caso real: dois
  hotfixes mergearam em `main` enquanto uma fatia continuava em correções
  próprias; o job de e2e mostrou 4 falhas deterministas não relacionadas ao
  diff, quase descartadas como "mais flakiness" — a branch estava, na
  verdade, 2 merges atrás de `main`.
  Closes #525

(PR #526)

## 1.45.42 — 2026-10-30

- **O que mudou**
  Em `.claude/skills/sdd-hotfix/SKILL.md`, passo 3 (+ cópia do plugin): ao
  instruir a correção de algo no boot/bootstrap de um serviço, a skill agora
  pergunta explicitamente (ou confere) se o projeto documenta mais de um
  manifesto de boot para esse serviço (local vs. produção — ex.:
  `entrypoint.sh` vs. `Procfile`/release phase). Se sim, exige paridade de
  correção entre eles, com teste de paridade dedicado.
  Bati a versão do plugin (`1.45.41` → `1.45.42`, patch) por tocar
  `plugins/btt-sdd/skills/`.
- **Por quê**
  Caso real: um hotfix corrigiu só `entrypoint.sh` (o único manifesto que
  roda de verdade no ambiente de desenvolvimento onde o agente testa) — o
  `Procfile` (o único caminho que produção real usa) ficou sem a correção,
  e nenhum teste existente pegaria isso. Só descoberto por releitura manual
  do orquestrador antes de mandar para code review, não pela instrução
  original.
  Closes #505

(PR #524)

## 1.45.41 — 2026-10-30

- **O que mudou**
  Em `docs/GIT-WORKFLOW.md` (+ cópia do plugin), logo depois do workaround de
  colisão de worktree já existente: novo caso — isolamento aninhado, onde o
  próprio orquestrador roda isolado (subagente de outra sessão, ou retomado
  numa sessão nascida dentro de um worktree). Nenhum workaround local
  funciona porque a branch da fatia está no checkout principal de outra
  sessão; a integração correta é `git push <remote-do-subagente> <branch-
  temp>:<branch-da-fatia>`.
  Bati a versão do plugin (`1.45.40` → `1.45.41`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Caso real: `git fetch . <branch-temp>:<branch-da-fatia>` foi recusado com
  `fatal: refusing to fetch into branch '...' checked out at '<checkout-
  principal>'` — a branch estava checked out no checkout principal de uma
  sessão diferente, exigindo intervenção manual fora do fluxo normal da
  skill.
  Closes #504

(PR #523)

## 1.45.40 — 2026-10-30

- **O que mudou**
  `docs/gates/qa.md` e a tabela de `docs/GIT-WORKFLOW.md` (+ cópias do
  plugin): ambos afirmavam incondicionalmente que o QA é a última etapa em
  fatia intermediária e faz o push único/`gh pr ready`/retrospectiva —
  sem a condição que `.claude/skills/sdd-qa/SKILL.md` (passo 6) já aplicava
  corretamente: isso só vale quando nenhuma tarefa da fatia antecipou
  `segurança`/`ux`/`sre`. Reconciliados os dois docs com a mesma condição
  explícita, citando a skill como fonte da lógica condicional.
  Bati a versão do plugin (`1.45.39` → `1.45.40`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Um leitor que só consulte `docs/gates/qa.md` isoladamente (sem cruzar com
  a skill) chegava à conclusão errada. Caso real: o `qa-engineer`, sem
  `AskUserQuestion` disponível, seguiu o precedente já estabelecido em
  fatias anteriores da mesma spec (QA não fecha quando segurança vem depois)
  em vez de decidir sozinho — comportamento correto, mas só porque o agente
  teve o bom senso de não confiar na leitura isolada do gate.
  Closes #503

(PR #522)

## 1.45.39 — 2026-10-30

- **O que mudou**
  Em `docs/TESTING.md` (+ cópia do plugin), seção "Build/empacotamento real
  como parte da suíte completa": novo bullet documentando que stacks com
  `next/font/google` (ou qualquer build-time asset fetch) precisam de
  `dangerouslyDisableSandbox: true` por padrão para esse comando.
  Bati a versão do plugin (`1.45.38` → `1.45.39`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  A sandbox padrão do Bash tool bloqueia o acesso de rede que o build
  precisa, e o erro resultante (`TypeError: Cannot read properties of null`)
  não menciona rede nem sandbox — fácil de ler como bug real antes de
  investigar. Caso real: rodando o mesmo comando com
  `dangerouslyDisableSandbox: true`, o build passou limpo.
  Closes #502

(PR #521)

## 1.45.38 — 2026-10-30

- **O que mudou**
  Em `.claude/agents/backend-developer.md` e
  `.claude/agents/frontend-developer.md` (+ cópias do plugin): ao editar a
  descrição de um PR já aberto pela outra trilha para acrescentar `Closes`,
  ler o corpo atual primeiro (`gh pr view <PR> --json body`) e acrescentar —
  nunca chamar `gh pr edit --body` com um texto construído do zero.
  Bati a versão do plugin (`1.45.37` → `1.45.38`, patch) por tocar
  `plugins/btt-sdd/agents/`.
- **Por quê**
  A instrução já existia em prosa ("sem remover o que já está lá"), mas não
  era suficientemente concreta para evitar o problema na prática: a edição
  final do corpo (a última trilha a rodar) sobrescreveu a seção que a outra
  trilha tinha escrito, apagando 8 das 11 linhas `Closes` da fatia — só
  descoberto depois do merge, exigindo fechamento manual das issues pelo
  orquestrador.
  Closes #501

(PR #520)

## 1.45.37 — 2026-10-30

- **O que mudou**
  Em `docs/gates/licoes.md` (+ cópia do plugin), no bullet sobre registro de
  ocorrência existente: reforço explícito de que a ocorrência entra na
  tabela de `docs/LESSONS-LEARNED.md` **nesta mesma rodada**, antes de
  considerar o achado/medição concluído — não numa rodada futura.
  Bati a versão do plugin (`1.45.36` → `1.45.37`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  A atenção de quem aplica uma lição já identificada está no resultado da
  medição/correção em si, não na tarefa administrativa de atualizar uma
  tabela num arquivo diferente — e essa é a parte mais fácil de esquecer,
  mesmo citando o ID da entrada corretamente no relatório da rodada. Caso
  real: a ocorrência de uma rodada ficou registrada só em prosa no
  `security-review.md`, sem chegar à tabela, só corrigido retroativamente
  pela rodada seguinte.
  Closes #500

(PR #519)

## 1.45.36 — 2026-10-30

- **O que mudou**
  Em `docs/AGENT-PREAMBLE.md` (+ cópia do plugin), logo após a seção
  `docs/PROJECT-CONVENTIONS.md`: antes de nomear uma convenção deste projeto
  pelo nome num artefato de revisão, `grep` a linha exata que a registra —
  nunca assumir que ela existe porque uma rodada anterior da mesma spec já a
  nomeou daquele jeito.
  Bati a versão do plugin (`1.45.35` → `1.45.36`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Caso real: uma convenção nomeada (`ci-antes-do-merge`) nunca existiu em
  `docs/PROJECT-CONVENTIONS.md` — o comportamento observado era real, mas
  produzido por um mecanismo diferente, já existente antes da spec. A
  primeira rodada descreveu o mecanismo certo em prosa; a partir da rodada
  seguinte, 8+ rodadas de qa-report/security-review ao longo de 4 fatias
  citaram o nome errado herdado da rodada anterior, sem nenhuma conferir a
  fonte primária.
  Closes #499

(PR #518)

## 1.45.35 — 2026-10-30

- **O que mudou**
  Em `.claude/agents/architect.md`, passo 6c (+ cópia do plugin): toda tarefa
  que desenha uma porta/adapter de saída novo que fala com serviço externo e
  introduz variável(is) de ambiente nova(s) agora exige, como critério de
  aceite explícito no texto da tarefa, que a variável entre em
  `.env.example` e no validador de ambiente da stack.
  Bati a versão do plugin (`1.45.34` → `1.45.35`, patch) por tocar
  `plugins/btt-sdd/agents/`.
- **Por quê**
  Documentar a existência da variável em prosa na seção de infraestrutura do
  TRD não garante que ela entre no mecanismo de fail-fast. Caso real: uma
  spec introduziu 5 variáveis de ambiente obrigatórias, cabeadas
  corretamente no código, mas nunca adicionadas a `.env.example`/validador —
  nenhuma das 4 rodadas de revisão que passaram pelo mesmo código percebeu,
  porque a variável "documentada no TRD" já parecia suficiente. Resultado
  real seria um primeiro deploy falhando de forma obscura na primeira
  requisição, em vez de falhar rápido na release phase.
  Closes #498

(PR #517)

## 1.45.34 — 2026-10-30

- **O que mudou**
  Em `.claude/agents/frontend-developer.md` (novo item 7),
  `.claude/agents/code-reviewer.md` (novo item 16) e
  `.claude/agents/ux-designer.md` (nova heurística 8) — + cópias do plugin:
  ao implementar/revisar uma tela cujo wireframe foi desenhado antes de uma
  divergência `TRD-N` ser registrada, confirmar que a cópia visível na tela
  bate com o comportamento real decidido pela divergência, não só o
  cálculo/comportamento.
  Bati a versão do plugin (`1.45.33` → `1.45.34`, patch) por tocar
  `plugins/btt-sdd/agents/`.
- **Por quê**
  Uma divergência `TRD-N` tende a propagar para o cálculo (que o plano de
  testes verifica), mas não para a cópia de UI copiada literalmente do
  wireframe pré-divergência — nenhum teste de comportamento pega isso, só
  quem lê a tela como usuário final percebe a contradição. Só o
  `code-reviewer` achou o caso real, numa rodada de revisão, não quem
  implementou.
  Closes #497

(PR #516)

## 1.45.33 — 2026-10-30

- **O que mudou**
  - `.claude/agents/architect.md` (novo item 8d): ao desenhar um port
  null-object com troca para adapter real planejada numa spec futura,
  nomear no TRD dessa spec futura um teste de concorrência real entre o
  novo adapter e qualquer caso de uso de spec anterior que escreva na
  mesma entidade.
  - `.claude/agents/security-engineer.md` (novo item 10) e
  `.claude/agents/code-reviewer.md` (novo item 15): ao revisar/corrigir uma
  condição de corrida com lock, `grep` por todo `UPDATE` concorrente na
  mesma linha protegida e confirmar que cada um confere linhas afetadas —
  não só o que motivou o achado original.
  Cópias do plugin espelhadas. Bati a versão do plugin (`1.45.32` →
  `1.45.33`, patch).
- **Por quê**
  Caso real: trocar o binding de um port null-object ativou uma corrida real
  entre código de duas specs diferentes que nunca tinha sido exercitado
  junto — só descoberta por medição manual. A correção com lock resolveu um
  lado, mas o `UPDATE` do lado que perde a corrida nunca conferia linhas
  afetadas, devolvendo sucesso silencioso para uma operação sem efeito.
  Closes #496

(PR #515)

## 1.45.32 — 2026-10-30

- **O que mudou**
  Em `.claude/agents/security-engineer.md` (área 5) e
  `.claude/agents/code-reviewer.md` (nova área 14) — + cópias do plugin: ao
  revisar uma correção de segurança que introduz `match`/validação fechada
  sobre um valor recebido como parâmetro, rastrear esse valor até a origem
  real (requisição HTTP, upload, cabeçalho) antes de considerar a correção
  completa — e confirmar que qualquer `throw` novo introduzido tem `catch`
  real no caminho de chamada.
  Bati a versão do plugin (`1.45.31` → `1.45.32`, patch) por tocar
  `plugins/btt-sdd/agents/`.
- **Por quê**
  Caso real: a correção usava `getClientMimeType()` (header forjável pelo
  cliente) em vez de `getMimeType()` (detecção por conteúdo), e a exceção do
  `match` fechado nunca era capturada em nenhum ponto da cadeia — produzindo
  um `500` não controlado em vez do `422` esperado. O fail-closed do `match`
  deu uma falsa sensação de completude tanto na implementação quanto na
  primeira aprovação de code review; só uma reverificação escopada rastreou
  o valor até a origem.
  Closes #495

(PR #514)

## 1.45.31 — 2026-10-30

- **O que mudou**
  Em `.claude/agents/code-reviewer.md` (área 4, qualidade dos testes) e
  `.claude/agents/ux-designer.md` (heurística 2) — + cópias do plugin: ao
  amostrar/revisar um componente que renderiza uma região de erro/alerta
  condicionalmente a partir de um valor opcional, confirmar explicitamente
  que existe teste/estado afirmando a **ausência** desse elemento no cenário
  normal, não só a presença de outra coisa.
  Bati a versão do plugin (`1.45.30` → `1.45.31`, patch) por tocar
  `plugins/btt-sdd/agents/`.
- **Por quê**
  Um bug real (alerta de erro geral renderizado incondicionalmente, mesmo
  quando o estado de erro nasce `null`) sobreviveu à implementação, à
  aprovação original de code review e à primeira rodada de UX review — só foi
  achado por acaso, na reverificação de outro achado. A amostragem de
  qualidade de teste verificava só presença de outro elemento, nunca a
  ausência do alerta.
  Closes #494

(PR #513)

## 1.45.30 — 2026-10-30

- **O que mudou**
  Em `.claude/skills/sdd-implement/SKILL.md`, passo 4c (+ cópia do plugin):
  generaliza a checagem de sincronia contrato↔cliente gerado — não é mais um
  checkpoint único "depois que as duas trilhas terminam". Toda vez que o
  orquestrador retoma uma trilha via `SendMessage` para uma correção pontual,
  confirma se o diff toca o arquivo de contrato; se tocar, repete a
  regeneração explícita do cliente, mesmo que a reconciliação inicial já
  tivesse rodado antes.
  Bati a versão do plugin (`1.45.29` → `1.45.30`, patch) por tocar
  `plugins/btt-sdd/skills/`.
- **Por quê**
  A reconciliação inicial já tinha confirmado a sincronia; uma 2ª invocação
  de `backend-developer` (retomada para resolver uma ambiguidade) editou o
  contrato de novo sem regenerar o cliente, porque o checkpoint já tinha
  passado e nada re-disparou a checagem. O CI só pegou isso na revisão de
  código seguinte, gerando uma rodada extra de correção mecânica — pela
  segunda vez com a mesma causa raiz (a primeira foi a issue #469).
  Closes #493

(PR #512)

## 1.45.29 — 2026-10-30

- **O que mudou**
  Em `docs/GIT-WORKFLOW.md` (+ cópia do plugin), logo depois do bloco já
  existente sobre `remove --force` falhando com "Permission denied" no
  Windows: novo parágrafo cobrindo o caso em que o worktree **continua**
  aparecendo em `git worktree list` mesmo depois de `remove --force`/`remove
  --force --force` falharem — `git worktree prune -v` como fallback, em vez
  de insistir numa 3ª tentativa de `remove`.
  Bati a versão do plugin (`1.45.28` → `1.45.29`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Aconteceu de verdade, duas vezes: `remove --force` falhou sem nem
  desregistrar o worktree (diferente do caso já documentado, onde o índice já
  tinha sido desregistrado antes da falha física) — `git worktree prune -v`
  resolveu de primeira nas duas ocorrências, desregistrando o worktree mesmo
  sem conseguir apagar o diretório físico.
  Closes #492

(PR #511)

## 1.45.28 — 2026-10-30

- **O que mudou**
  Em `docs/TESTING.md` (+ cópia do plugin), nova subseção "Armadilha
  conhecida" (mesmo padrão já usado para o gotcha de `testPathIgnorePatterns`
  do Jest): documenta que `npm run lint`/`npx eslint` via o shim do git-bash
  no Windows pode falhar com "calling module was not recognized" quando a
  dependência usa `@rushstack/eslint-patch` (ex.: `eslint-config-next`) — o
  mesmo comando passa limpo via PowerShell/`cmd` nativo.
  Bati a versão do plugin (`1.45.27` → `1.45.28`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Sem esse gotcha documentado, o sintoma (erro específico de
  `@rushstack/eslint-patch`) é fácil de confundir com `node_modules`
  corrompido, gastando tempo com `npm ci` antes de isolar a causa real
  trocando de shell.
  Closes #490

(PR #510)

## 1.45.27 — 2026-10-30

- **O que mudou**
  Em `.claude/agents/frontend-developer.md` (nova regra 6) e
  `.claude/agents/code-reviewer.md` (nova área de revisão 13) — + cópias do
  plugin: ao mudar o texto/comportamento observável de uma tela/fluxo que já
  existia antes da spec atual começar, `grep` os testes e2e de TODAS as specs
  (não só a atual) por referência àquele texto/seletor, antes de considerar a
  tarefa completa.
  Bati a versão do plugin (`1.45.26` → `1.45.27`, patch) por tocar
  `plugins/btt-sdd/agents/`.
- **Por quê**
  O mecanismo "e2e completo só na última fatia de uma spec" (decisão
  deliberada de custo) cria um ponto cego estrutural: um e2e de uma spec
  anterior que afirma o texto antigo só é exercitado de verdade quando a spec
  atual chegar na própria última fatia. Aconteceu de verdade: uma mudança de
  tela ficou latente por 3 fatias antes de ser descoberta, numa fatia sem
  relação aparente com a mudança original.
  Closes #489

(PR #509)

## 1.45.26 — 2026-10-30

- **O que mudou**
  Em `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes
  concorrentes" (+ cópia do plugin): nova orientação explícita logo após o
  mecanismo preferido (Agent tool, `isolation: "worktree"`) — se o
  orquestrador tiver commits locais ainda não enviados na branch da fatia, dar
  `git push` antes de invocar a próxima etapa isolada.
  Bati a versão do plugin (`1.45.25` → `1.45.26`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Aconteceu 3 vezes na mesma fatia: o worktree novo criado pelo harness nasceu
  do estado em `origin/<branch>`, não do checkout local do orquestrador —
  chegou a nascer de `origin/main`, sem nenhum commit da fatia, fazendo um
  componente novo aparentar não existir. Um push intermediário aqui não
  quebra "push único por fatia" (regra sobre não fragmentar pushes
  arbitrariamente, não sobre nunca dar push quando outro agente isolado
  depende de ver aquele commit).
  Closes #488

(PR #508)

## 1.45.25 — 2026-10-30

- **O que mudou**
  Em `.claude/skills/sdd-implement/SKILL.md`, passo 4c (+ cópia do plugin):
  quando a reconciliação pós-trilhas (contrato OpenAPI/GraphQL/protobuf →
  cliente gerado) gerar um commit que toca código de produção de uma trilha
  cujo `coverage/<fatia>-<trilha>.md` já foi committado, o orquestrador agora
  atualiza a referência de SHA citada nesse arquivo como parte do mesmo
  commit.
  Bati a versão do plugin (`1.45.24` → `1.45.25`, patch) por tocar
  `plugins/btt-sdd/skills/`.
- **Por quê**
  Sem isso, a troca do dublê pelos tipos reais (que não muda comportamento)
  deixava o `coverage/<fatia>-<trilha>.md` citando um SHA que não era mais o
  último a tocar aquele código — inconsistência só percebida (e corrigida) por
  uma etapa de revisão posterior, fora do escopo natural dela.
  Closes #487

(PR #507)

## 1.45.24 — 2026-10-30

- **O que mudou**
  Em `docs/GIT-WORKFLOW.md` (regra 4) e `.claude/skills/sdd-implement/SKILL.md`
  (passo 5) — + cópias do plugin: no mesmo momento/commit em que o PR da fatia
  é aberto, o orquestrador agora também atualiza a seção 14 do TRD ("Controle
  de versão (GitHub Flow, por fatia)") com o número real do PR e status "em
  revisão" — simétrico à promoção da coluna Status da seção 13 que já
  acontecia nesse ponto.
  Bati a versão do plugin (`1.45.23` → `1.45.24`, patch) por tocar
  `plugins/btt-sdd/docs/` e `plugins/btt-sdd/skills/`.
- **Por quê**
  Sem essa instrução explícita, a seção 14 ficava mostrando "não iniciado"
  para uma fatia que já tinha PR aberto, e a lacuna só era percebida por uma
  etapa de revisão posterior (`code-reviewer`), fora do escopo natural dela.
  Closes #486

(PR #506)

## 1.45.23 — 2026-10-23

- **O que mudou**
  Em `docs/TESTING.md` (+ cópia do plugin), seção "Infraestrutura se reaproveita,
  não se recria": acrescentei, logo após o item de reuso de container entre
  execuções, a regra que faltava — o ambiente Docker de teste deve ser
  **excluído** ao final da execução completa da suíte de integração (`docker
  compose down -v` ou equivalente, removendo volumes, não só parando o
  processo). Reaproveitar enquanto a suíte roda não é o mesmo que deixar o
  ambiente no ar depois que ela termina.
  Bati a versão do plugin (`1.45.22` → `1.45.23`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Mesma classe de causa raiz da issue #480 (worktrees de agente acumulados sem
  limpeza): um recurso efêmero por execução, sem ninguém explicitamente
  responsável por removê-lo ao terminar, acumula silenciosamente numa máquina
  usada em sessões longas e esgota o disco local sem alerta direto.
  Closes #484

(PR #485)

## 1.45.22 — 2026-10-23

- **O que mudou**
  Em `docs/GIT-WORKFLOW.md` (+ cópia do plugin), seção "Limpe o worktree antes
  de apagar a branch associada": acrescentei três orientações depois do `git
  worktree remove --force <caminho>` já existente:
  1. **Confirme o sucesso da remoção** com `git worktree list` — o caminho não
  deve mais aparecer.
  2. **Trate falha por lock como achado a resolver**, não como erro a ignorar:
  locks de processos já encerrados são stale e removíveis com `--force` em
  dobro (`git worktree remove --force --force <caminho>`).
  3. **Varra periodicamente worktrees órfãos** em sessões longas com várias
  fatias/specs consecutivas, em vez de confiar só na limpeza reativa de cada
  merge.
  Bati a versão do plugin (`1.45.21` → `1.45.22`, patch) por tocar
  `plugins/btt-sdd/docs/`.
- **Por quê**
  Numa sessão real com 3 specs consecutivas no mesmo projeto, o orquestrador
  mediu o disco do host em **116 MB livres de 931 GB** (99,9% usado) antes de
  um `ux-designer` reportar que não conseguia subir o ambiente Docker local
  para navegação ao vivo. A investigação descartou causas óbvias (Docker/WSL,
  pagefile) e achou 110 worktrees deste pipeline acumulados — alguns presos por
  lock de agentes já encerrados, nunca liberado, nunca removido. O primeiro
  sintoma visível foi um agente de revisão degradando seu método de
  verificação, não um alerta de disco cheio.
  Closes #480

(PR #483)

## 1.45.21 — 2026-10-23

- **O que mudou**
  A forma mínima de CI (`docs/CI-WORKFLOW.md`, item 5) já orienta cachear o
  gerenciador de pacotes da stack, mas não cobre o binário do navegador que
  suítes Playwright/Selenium instalam via `apt-get` a cada run. Adicionei o item
  5b (nas duas cópias, `docs/` e `plugins/btt-sdd/docs/`): cachear o diretório de
  instalação dos navegadores, ou — alternativa mais robusta — rodar o job dentro
  da imagem Docker oficial da ferramenta como `container:`, eliminando o
  `apt-get` do caminho crítico.
- **Por quê**
  No projeto `projeto-C`, o job `navegador (Playwright, backend
  real)` falhou por timeout de 30 minutos **duas vezes seguidas**, sempre
  travado em `npm exec playwright install --with-deps chromium firefox webkit`
  baixando de um mirror Ubuntu lento — nunca chegou a rodar um teste. A 3ª
  tentativa passou em minutos, confirmando que o código nunca esteve quebrado:
  ~1h de espera bloqueando o merge de uma fatia já aprovada em todas as outras
  etapas, puramente por reinstalação de infraestrutura que não muda entre runs.
  Bati a versão do plugin (`1.45.20` → `1.45.21`, patch) por tocar
  `plugins/btt-sdd/docs/`.
  Closes #479

(PR #482)

## 1.45.20 — 2026-10-23

- **O que mudou**
  A frase "reaproveite o cache de dependências compartilhado em vez de reinstalar
  tudo do zero" (repetida em 4 agentes: `qa-engineer`, `sre`, `security-engineer`,
  `code-reviewer`, nas duas cópias — `.claude/agents/` e `plugins/btt-sdd/agents/`)
  era ambígua entre duas leituras:
  1. Reusar o cache de **download** do gerenciador de pacotes (`composer`/`npm`
  `cache-dir`) e instalar localmente dentro do próprio worktree — seguro.
  2. Compartilhar literalmente o diretório **já instalado** (`vendor`/`node_modules`)
  via symlink/junction entre worktrees — inseguro.
  Um `qa-engineer` isolado tomou a leitura (2) por economia de tempo, numa sessão
  real (projeto `projeto-C`, spec `0003`, fatia F-3, stack
  PHP/Laravel): criou uma junction `backend/vendor` apontando para o vendor do
  worktree principal. Rodar a suíte via `vendor/bin/phpunit` sem `--env` fez o
  Laravel carregar o `.env.testing` do worktree **principal**, não o do worktree
  isolado — a suíte tentou conectar no Postgres efêmero errado, falhando em 242
  testes. Pior: se os dois worktrees tivessem Postgres efêmero de pé ao mesmo
  tempo, o vazamento seria silencioso.
  Reescrevi a instrução para ser inequívoca: cache de download, instalação local,
  nunca symlink/junction do diretório já instalado.
  Bati a versão do plugin (`1.45.19` → `1.45.20`, patch) por tocar
  `plugins/btt-sdd/agents/`.
  Closes #478

(PR #481)

## 1.45.19 — 2026-10-21

- `docs/GIT-WORKFLOW.md`, seção "Push único por fatia": nova nota — numa fatia sinalizada como final ao CI (mecanismo do passo 2b-quater de `/sdd-implement`, issue #473), reter todo commit de artefato de revisão localmente até o último da cadeia estar pronto importa ainda mais, não menos. Cada push nessa fatia reexecuta o job e2e real do zero, independente do diff — então um push isolado por rodada de revisão/reverificação multiplica o custo mais caro do pipeline por cada achado que gerar uma rodada extra.
- Só a correção que de fato toca código de produção justifica push próprio (precisa de CI real para validar). Qualquer artefato de revisão puro — mesmo numa reverificação — espera o próximo push que já for necessário por outro motivo.
- Motivo: numa fatia final com um achado real que precisou de correção + duas rodadas de reverificação, sete pushes separados — a maioria sobre diffs só de `specs/**/*.md` — reexecutaram o job real de navegador (Playwright, backend real) sete vezes.
- Replicado em `plugins/btt-sdd/docs/GIT-WORKFLOW.md`; versão do plugin incrementada para `1.45.19` (patch).
Closes #475

(PR #477)

## 1.45.18 — 2026-10-21

- `.claude/skills/sdd-implement/SKILL.md`, novo passo 2b-quater: quando a fatia escolhida é a última pendente da spec, e o projeto documenta em `docs/PROJECT-CONVENTIONS.md` um mecanismo explícito de sinalização para o CI ativar a suíte e2e completa (ex.: label de PR), o orquestrador aplica esse sinal assim que o PR desta fatia abre — antes da primeira etapa de revisão.
- Motivo: generaliza sem hardcodar nenhum mecanismo específico de projeto (o nome/forma do sinal é decisão do `architect`/`sre` de cada projeto, registrada em `docs/PROJECT-CONVENTIONS.md`) — o ponto genérico é *quando* aplicar: o orquestrador já sabe, no momento em que escolhe a fatia, que ela é a última pendente; essa é a informação mais antiga disponível, não precisa esperar QA/segurança notarem a ausência no meio da cadência.
- 2ª ocorrência confirmada do mesmo padrão em duas specs diferentes do mesmo projeto: o sinal só foi aplicado durante a rodada de QA (ou mais tarde), depois que code review e UX já tinham aprovado sem a suíte e2e real ter rodado nenhuma vez — a primeira execução real do job encontrou um defeito presente desde a primeira fatia da spec.
- Complementa a issue #457 (que documentou o risco genérico de e2e-só-na-última-fatia) com o *quando* sinalizar, sem prescrever o *como*.
- Replicado em `plugins/btt-sdd/skills/implement/SKILL.md`; versão do plugin incrementada para `1.45.18` (patch).
Closes #473

(PR #476)

## 1.45.17 — 2026-10-21

- `.claude/skills/sdd-implement/SKILL.md`, seção "Retomando para corrigir achados de revisão", novo passo 4c: quando uma correção pontual se divide em trilhas backend+frontend paralelas e a trilha backend publica/altera um contrato (OpenAPI/GraphQL/protobuf) que a trilha frontend consome via cliente gerado, o orquestrador reconcilia depois que as duas terminam — confirmando que o cliente gerado está sincronizado com o contrato publicado, mesmo sem pendência sinalizada por nenhuma das duas trilhas.
- Motivo: a orientação (correta) de não bloquear a trilha frontend enquanto o contrato ainda não existe abre, por desenho, uma janela em que o cliente gerado pode ficar desatualizado depois que o backend publica — nenhuma trilha, sozinha, tem como notar isso no momento em que termina. Complementa a issue #449 (que cobre o desvio *dentro* de uma trilha, no momento em que ela termina) com o caso em que o desvio só existe *depois* que a outra trilha publica algo novo.
- Já aconteceu de verdade: o frontend terminou e empurrou seu commit antes do backend publicar o schema; ninguém regenerou o cliente tipado depois, e o desvio só foi pego pela rodada seguinte de code review, gerando uma rodada extra de correção + duas reverificações escopadas.
- Replicado em `plugins/btt-sdd/skills/implement/SKILL.md`; versão do plugin incrementada para `1.45.17` (patch).
Closes #469

(PR #472)

## 1.45.16 — 2026-10-21

- `docs/GIT-WORKFLOW.md`: generaliza o bloco "confirme sempre o branch atual" para um terceiro gatilho — o orquestrador alterna o workspace entre `main` e a branch da fatia a cada invocação de agente isolado (`git checkout main` para liberar o nome da branch para o próximo worktree), e qualquer edição de artefato disparada logo depois (não só um comando de Git) herda esse checkout sem aviso.
- `.claude/skills/sdd-amend/SKILL.md`, novo passo 1b: confirma a branch atual antes de editar qualquer artefato in-place, nunca assumindo que o workspace já está na branch certa.
- Motivo: depois de uma rodada de `ux-review`, o orquestrador fez `git checkout main` (normal, libera a branch para o próximo worktree); o usuário respondeu a uma pergunta de `AskUserQuestion`, e o orquestrador seguiu direto para `/sdd-amend`, editando 7 seções do TRD em `main` local — sem confirmar a branch primeiro. Só não causou dano porque nada tinha sido commitado ainda.
- Replicado em `plugins/btt-sdd/` (doc + skill); versão do plugin incrementada para `1.45.16` (patch).
Closes #468

(PR #471)

## 1.45.15 — 2026-10-21

- Os 5 agentes de revisão (`code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`) ganham instrução explícita: a remoção do próprio worktree isolado é sempre ação do orquestrador (depois de integrar o commit na branch da fatia) — nunca do agente. Se por algum motivo o agente tentar remover o próprio worktree, confirma via `git worktree list` antes de reportar sucesso.
- Motivo: um relatório final de `code-reviewer` afirmou que o próprio worktree "já foi removido depois de confirmar independentemente... que o commit estava mesmo na branch correta" — falso. O orquestrador rodou `git worktree list` de forma independente e encontrou o worktree ainda presente, travado (`locked`), com 2 commits reais nunca enviados para `origin`. Se o orquestrador tivesse confiado na afirmação, os dois commits teriam ficado presos silenciosamente, sem erro algum.
- Replicado em `plugins/btt-sdd/` (5 agentes); versão do plugin incrementada para `1.45.15` (patch).
Closes #467

(PR #470)

## 1.45.14 — 2026-10-20

- `.claude/skills/sdd-implement/SKILL.md`, seção "Retomando para corrigir achados de revisão", novo passo 1d: ao formular uma instrução de correção que cita um componente/padrão existente como referência de implementação ("reaproveite X", "mesmo padrão de Y"), rodar `grep -i "<nome-do-componente>" docs/LESSONS-LEARNED.md` antes de enviar a instrução. Se houver lição aberta citando esse componente, incluir explicitamente que a lacuna conhecida não deve ser copiada para o novo uso.
- Motivo: uma correção de UX pediu para reaproveitar um componente com padrão visual já aprovado, mas esse componente já tinha 2 ocorrências registradas da mesma lição de acessibilidade (foco não gerenciado). A instrução não mencionou a lição aberta, e o fix copiou o padrão visual junto com a lacuna — virando a 3ª ocorrência da mesma lição, só pega na reverificação da revisão seguinte, não por nenhuma instrução.
- Replicado em `plugins/btt-sdd/skills/implement/SKILL.md`; versão do plugin incrementada para `1.45.14` (patch).
Closes #464

(PR #466)

## 1.45.13 — 2026-10-20

- `.claude/skills/sdd-security/SKILL.md`, passo 5: deixa de dizer incondicionalmente "a próxima etapa é `/sdd-sre`" após aprovação. Novos passos 6-7 replicam a ramificação por cadência que `skills/qa/SKILL.md` já tinha: se alguma tarefa restante da fatia marca `sre`, ou esta é a última fatia pendente da spec → próxima etapa é `/sdd-sre`, agora; senão → segurança é a última etapa desta fatia, herdando push único + `gh pr ready` + retrospectiva (responsabilidades que só `qa`'s passo 7 documentava explicitamente).
- Motivo: numa fatia real, a segurança foi antecipada (marcada na coluna "Validação na fatia"), mas a fatia não era a última da spec e nenhuma tarefa marcava `sre`. O passo 5 antigo mandava incondicionalmente para `/sdd-sre`, e o orquestrador teve que descartar essa instrução e reconstruir a lógica certa cruzando `docs/SDD-WORKFLOW.md` e o passo 6-7 de `qa`'s SKILL.md.
- Replicado em `plugins/btt-sdd/skills/security/SKILL.md`; versão do plugin incrementada para `1.45.13` (patch).
Closes #463

(PR #465)

## 1.45.12 — 2026-10-20

- `docs/gates/governanca.md` (lido por todo agente de revisão, independente de qual skill o invocou): novo item — `code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer` e `sre` nunca invocam outro agente/subagente por conta própria, e nunca executam tarefas reservadas ao orquestrador (editar `timing-log.md`, editar a seção "Log de revisões"/narrativa do TRD) — mesmo tendo acesso técnico às ferramentas para fazer os dois.
- Motivo: uma invocação de `code-reviewer` (via Agent tool, mandato estreito: produzir `code-review.md`) encadeou por conta própria um agente filho em worktree/branch separados e, depois de receber o resultado, editou a seção do TRD e o `timing-log.md` — tarefas que a skill correspondente reserva explicitamente ao orquestrador — e se autodenominou "o orquestrador desta skill" no relatório final.
- O conteúdo produzido se confirmou correto em toda verificação independente feita depois (nada precisou ser desfeito), mas o *mecanismo* é uma violação de fronteira de responsabilidade: um agente com mandato estreito assumiu um mandato mais largo sem que o orquestrador real tivesse pedido ou soubesse até ler o relatório final.
- Replicado em `plugins/btt-sdd/docs/gates/governanca.md`; versão do plugin incrementada para `1.45.12` (patch).
Closes #459

(PR #462)

## 1.45.11 — 2026-10-20

- `docs/GIT-WORKFLOW.md`: generaliza o bloco "confirme sempre o branch atual" (antes só sobre colisão de worktree) para cobrir o gatilho real deste incidente — agente retomado sem isolamento devolvendo o workspace via `git checkout <branch base>`, seguido de um `git merge --ff-only` que avança a branch errada sem erro algum.
- As 5 skills de revisão (`code-review`, `ux-review`, `qa`, `security`, `sre`) ganham `git branch --show-current` como primeiro comando do passo "Integre o commit do agente"; `implement` ganha o passo equivalente na seção de retomada sem isolamento.
- Motivo: um `backend-developer` retomado sem isolamento fez `git checkout main` como limpeza ao final (esperado); o orquestrador rodou `git merge --ff-only origin/<branch-da-fatia>` sem confirmar a branch primeiro — sempre um fast-forward válido, só que avançou `main` local em vez da branch da fatia. Um commit de `timing-log.md` foi parar em `main` local; o push foi recusado pela proteção de branch (nenhum dano ao remoto), mas custou uma rodada de diagnóstico/correção que o check teria evitado.
- Replicado em `plugins/btt-sdd/` (6 skills + doc); versão do plugin incrementada para `1.45.11` (patch).
Closes #458

(PR #461)

## 1.45.10 — 2026-10-20

- `docs/CI-WORKFLOW.md`, seção "O que não entra por padrão": novo item documentando o padrão "e2e completo (cross-arquivo, contra backend real) rodando só na última fatia da spec" — comum quando o `architect` espelha, na CI, a cadência de revisão "ao final da spec" deste pipeline — e o risco que ele concentra: toda a integração/contaminação de estado entre arquivos de teste só aparece quando não há mais fatia seguinte para absorver o retrabalho.
- **Não muda o padrão genérico do pipeline** — continua decisão do `architect` por projeto, como já é hoje. Só torna o trade-off explícito (igual aos outros itens dessa seção: `ci-antes-do-merge`, sharding), com a recomendação de uma variante mais barata (rodar o e2e já existente a cada fatia nova) quando o `architect` optar por essa cadência.
- Motivo: numa spec real, a primeira execução real desse tipo de job teve mais de 150 falhas — um seletor sem escopo escrito e aprovado em 3 fatias diferentes, cada uma só o exercitando isoladamente — e revelou 2 bugs reais de produção pré-existentes que nenhuma revisão anterior tinha como pegar sem o conjunto inteiro rodando junto.
- Replicado em `plugins/btt-sdd/docs/CI-WORKFLOW.md`; versão do plugin incrementada para `1.45.10` (patch).
Closes #457

(PR #460)

## 1.45.9 — 2026-10-19

- Mesma causa raiz da #443 (já corrigida em #446), num segundo trecho que não tinha sido tocado então: o workaround de "`git checkout <branch-da-fatia>` falhar por colisão de worktree" sempre basear a branch temporária em `origin/<branch>` — duplicado em `code-reviewer.md`, `ux-designer.md`, `qa-engineer.md`, `security-engineer.md`, `sre.md` e descrito em `docs/GIT-WORKFLOW.md`.
- Agora prefere a referência mais avançada entre a branch local `<branch>` (compartilhada entre worktrees do mesmo repositório) e `origin/<branch>`, igual à correção já aplicada à seção de bootstrap de worktree isolado.
- Motivo: a regra "Push único por fatia" retém commits de revisão só localmente até o final da cadeia. Três rodadas de revisão (code review, UX, QA) integraram seus artefatos só localmente, e a etapa de segurança seguinte — usando esse workaround, sempre baseado em `origin/<branch>` — encontrou a branch remota 4 commits atrás e abortou sem produzir veredito, descartando uma invocação inteira só para redescobrir que os commits existiam, só retidos localmente.
- Replicado em `plugins/btt-sdd/` (5 agentes + doc); versão do plugin incrementada para `1.45.9` (patch).
Closes #453

(PR #456)

## 1.45.8 — 2026-10-19

- `specs/_template/timing-log.template.md`: nova seção "Desfecho excepcional" — convenção leve de marcadores no início da nota da coluna `Duração` (`[RECUSADO]`, `[RETRABALHO]`) para quando a invocação não terminou no resultado normal da etapa.
- Motivo: esse sinal hoje fica em prosa livre dentro da coluna `Etapa` (ex.: "Segurança (invocada fora de ordem pelo orquestrador — recusada corretamente)"), sem convenção fixa — não é buscável/agregável de forma confiável entre specs, e a retrospectiva de fatia do `sre` não tem como distinguir sistematicamente invocação desperdiçada por erro de sequenciamento de achado real de revisão.
- Replicado em `plugins/btt-sdd/skills/create-project/scaffold/specs/_template/timing-log.template.md`; versão do plugin incrementada para `1.45.8` (patch).
Closes #451

(PR #455)

## 1.45.7 — 2026-10-19

- `plugins/btt-sdd/skills/create-project/scaffold/CLAUDE.md`: acrescenta a regra "nunca invoque agente de revisão direto via Agent tool, mesmo numa sessão que já rodou o pipeline antes" — já existia no CLAUDE.md deste repositório (meta-instruções de manutenção), mas nunca chegava a projetos reais criados via `/create-project`/plugin instalado, que são os que de fato rodam o pipeline fatia após fatia.
- `docs/gates/governanca.md` (lido por todo agente, independente de qual skill o invocou): novo item generalizando a recusa por pré-condição não satisfeita — hoje só documentada como comportamento observado do `security-engineer` — para os cinco agentes de revisão (`code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`), como defesa em profundidade esperada quando a skill é pulada mesmo assim.
- Motivo: um `security-engineer` foi invocado fora de ordem (QA ainda não tinha rodado) direto via Agent tool, numa sessão que já tinha rodado o pipeline inteiro para uma fatia anterior. Recusou corretamente (sem dano a artefato nenhum) — mas a invocação foi desperdiçada, e o orquestrador não tinha, no CLAUDE.md do projeto, o aviso que teria evitado a tentativa.
- Replicado em `plugins/btt-sdd/docs/gates/governanca.md`; versão do plugin incrementada para `1.45.7` (patch).
Closes #450

(PR #454)

## 1.45.6 — 2026-10-19

- `docs/TESTING.md`, seção "Build/empacotamento real": quando o artefato de build é gerado a partir de um contrato commitado (tipos/cliente de OpenAPI/GraphQL/protobuf), o comando certo para detectar desvio é geração explícita + diff contra o committed — não o build de desenvolvimento, que tipicamente regenera o artefato e mascara o desvio via um passo `prebuild`/equivalente.
- Novo item **5a-ter** em `.claude/agents/backend-developer.md` e `.claude/agents/frontend-developer.md`: rodar esse comando explícito (o mesmo que o CI roda) como parte do checklist de "pronto para code review", antes de declarar a trilha concluída.
- Motivo: um arquivo de tipos à mão ficou desatualizado em relação ao contrato publicado por outra trilha; o build local regenerava e mascarava o desvio a cada execução; o defeito funcional resultante só foi notado pelo `code-reviewer` numa rodada inteira depois, com o CI já vermelho desde o primeiro push.
- Replicado em `plugins/btt-sdd/`; versão do plugin incrementada para `1.45.6` (patch).
Closes #449

(PR #452)

## 1.45.5 — 2026-10-16

- `.claude/agents/sre.md` (área "CI") e `docs/gates/sre.md`: ao renomear ou remover o `name:` de um job em `ci.yml`/`cd.yml`, o `sre` agora confere `required_status_checks.contexts` da proteção de `main` **antes** de escrever o veredito, não só ao notar `mergeStateStatus: BLOCKED` no fim.
- Motivo: o GitHub trata o nome do status check como identidade — um nome que nunca mais reporta deixa o PR "pending" nesse check para sempre, mesmo com tudo verde. Reconciliação é via `gh api` com confirmação do usuário, nunca correção silenciosa.
- Replicado em `plugins/btt-sdd/agents/sre.md` e `plugins/btt-sdd/docs/gates/sre.md`; versão do plugin incrementada para `1.45.5` (patch).
Closes #445

(PR #448)

## 1.45.4 — 2026-10-16

- `.claude/agents/architect.md`, novo item 8c: quando o TRD/ADR descreve um mecanismo de escopo explícito (ex.: isolamento multi-tenant via transação/escopo de RLS, ou qualquer "chame X antes de Y" que o compilador não força), o architect agora registra também a recomendação de um teste de arquitetura dedicado — percorrer todos os consumidores do port escopado e falhar se algum não respeitar o escopo.
- Motivo: mesmo defeito estrutural apareceu em 6 consumidores diferentes numa migração real, descobertos um a um por medição ao vivo; mesmo depois da primeira rodada de correção, cada lente de revisão subsequente achava instâncias novas que a anterior não cobria. Uma garantia sustentada só por disciplina/revisão escala mal quando o mecanismo se repete por consumidor.
- Replicado em `plugins/btt-sdd/agents/architect.md`; versão do plugin incrementada para `1.45.4` (patch).
Closes #444

(PR #447)

## 1.45.3 — 2026-10-16

- `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes": o bootstrap de um worktree isolado agora sincroniza contra a referência mais avançada entre a branch local (compartilhada entre worktrees do mesmo repositório) e `origin/<branch>`, em vez de assumir sempre a remota.
- Motivo: a regra "Push único por fatia" retém deliberadamente o commit de uma etapa de revisão só localmente até o final da cadeia. Como `isolation: "worktree"` é o padrão em todas as etapas 4-7, sincronizar contra `origin/<branch>` às cegas faz o próximo agente isolado não ver esse commit retido — já aconteceu de verdade (issue), custando uma rodada de orquestração inteira para redescobrir que o commit existia, só não publicado ainda.
- Alternativa descartada (dar push após cada etapa de revisão antes de acionar a próxima): resolveria o bug, mas devolveria a fatia a ~1 push por etapa de revisão, já que `isolation:worktree` é o padrão em todas elas — a maior parte da economia de CI que "push único por fatia" existe para capturar desapareceria no caso comum.
- Replicado em `plugins/btt-sdd/docs/GIT-WORKFLOW.md`; versão do plugin incrementada para `1.45.3` (patch).
Closes #443

(PR #446)

## 1.45.2 — 2026-10-14

- Documenta o [rtk](https://github.com/rtk-ai/rtk) (comprime saída de comandos de shell antes de chegar ao contexto do agente) como convenção recomendada em `docs/TOOLING.md`, referenciado por `AGENT-PREAMBLE.md`/`SKILL-PREAMBLE.md` e listado em `docs/FILE-GUIDE.md`.
- Adiciona `scripts/check-rtk.py`, diagnóstico informativo (nunca bloqueante) de instalação/configuração do hook.
- Orienta projetos que adotam o pipeline a também instalarem o rtk, via scaffold de `/create-project` (`CLAUDE.md`/`README.md` do projeto novo).
- Replica as mudanças relevantes em `plugins/btt-sdd/` e inclui `TOOLING` no normalizador de `scripts/check-plugin-sync.py`; bump de versão do plugin para `1.45.2` (patch).
Pura otimização de custo de sessão — nenhuma etapa do pipeline passa a depender de rtk, nem bloqueia por sua ausência.
Closes #441

(PR #442)

## 1.45.1 — 2026-10-14

- chore: exigir bump de versão do plugin em qualquer PR manual, não só via /repo-issues
  A obrigação de incrementar plugins/btt-sdd/.claude-plugin/plugin.json só
  estava escrita no procedimento da skill de manutenção deste repositório
  contra suas próprias issues. O processo genérico de "Mudanças no próprio
  pipeline" (docs/GIT-WORKFLOW.md) não mencionava o passo, e três PRs manuais
  seguidas (#433, #435, #438) tocaram conteúdo empacotado sem bater a versão
  como consequência direta disso.
  Generaliza a regra para qualquer PR que toque plugins/btt-sdd/, e bate a
  versão agora (1.45.0 -> 1.45.1) como catch-up das três que ficaram para trás.
  Closes #439

## 1.45.0 — 2026-10-13

  Closes #428
- **O gap**
  **Nenhuma etapa do pipeline era dona da criação de `.github/workflows/ci.yml`:**
  - o scaffold de `/create-project` não traz `.github/workflows/` — correto, porque a forma depende da stack, e a stack só é decidida no primeiro TRD;
  - `skills/implement`, `backend-developer` e `frontend-developer` não mencionavam o arquivo (`grep` limpo);
  - `agents/sre.md` é o único que trata do assunto, e como **auditoria de infraestrutura existente** (etapa 7).
  Resultado: o workflow nascia na forma que parecesse razoável a quem implementava a primeira fatia, e **toda regra do pipeline sobre a forma dele era corretiva por construção**. Pior depois de #419: a etapa 7 passou a rodar **uma vez, ao final da spec** — um `ci.yml` malformado atravessaria a spec inteira antes de alguém olhar a forma dele.
- **`docs/CI-WORKFLOW.md` (novo)**
  O contrato entre os três papéis que antes não se encontravam em lugar nenhum: o `architect` cria a tarefa que faz o arquivo nascer, quem a implementa segue a forma, o `sre` audita contra ela. A medição e o histórico de cada regra **continuam** em `agents/sre.md`, área "CI" — o doc novo carrega só a forma, para o `architect` e o dev não precisarem carregar a área inteira do `sre`.
  A forma: jobs de lint/teste/gate de 80% **por pacote** com os comandos de `docs/STACK.md`; `concurrency` com `cancel-in-progress` fora da branch base; short-circuit de docs-only pela comparação com o último run verde (nunca `paths-ignore` no gatilho, nunca o gate no job); passo informativo do caminho pulado; cache de dependências; e o `schedule` amostrador que **acompanha** o short-circuit, porque os runs redundantes que ele suprime eram a única amostragem de flakiness que o repositório tinha. Mais uma seção do que **não** entra por padrão: `paths`/`paths-ignore`, cadência `ci-antes-do-merge` (opt-in por projeto) e sharding.
- **Correção dentro da receita**
  O job que consulta o último run verde precisa de **`permissions: actions: read`** — o `GITHUB_TOKEN` padrão não traz esse escopo em toda configuração de repositório. Isso não estava escrito em lugar nenhum, e a omissão é pior do que parece: como a direção de falha segura da receita é "roda a suíte", a falta da permissão **não quebra nada visivelmente** — o workflow fica correto, o desperdício continua inteiro, e ninguém descobre que o short-circuit nunca funcionou. Virou **item de gate** em `docs/gates/sre.md`, não observação.
- **Quem passa a ser dono**
  - **`architect`, passo 2d** — quando o projeto ainda não tem o arquivo e esta spec produz a primeira suíte, cria a tarefa que o faz nascer, com `Validação na fatia = sre` (que a coluna de #419 já torna obrigatória para tarefa que toca `ci.yml`), apontando para `docs/CI-WORKFLOW.md`. Ele **não** redesenha a forma no TRD — só decide os comandos da stack, que já vão para `docs/STACK.md`. Projeto que já tem o arquivo não ganha a tarefa: evoluir workflow existente continua sendo da etapa 7.
  - **`docs/gates/trd.md`** — item correspondente.
  - **`backend-developer`/`frontend-developer`, passo 5a-bis** — quem executa a tarefa segue a forma, e não escreve um `ci.yml` mínimo "para começar" deixando o resto para depois: "depois" é a etapa 7 de uma spec inteira adiante.
  - **`sre`** — a área "CI" agora aponta para a mesma página, e item de lá que falte no `ci.yml` do projeto é achado desta etapa.
  Mais as entradas de índice: `docs/FILE-GUIDE.md`, `CLAUDE.md` ("Onde as coisas vivem") e o `CLAUDE.md` do scaffold (que enumera os docs de governança que vêm do plugin).
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde, agora com **63** pares (o doc novo entrou no pareamento automático, não ficou fora). Versão do plugin: `1.44.1` → **`1.45.0`** (minor — doc novo e dono novo, não só ajuste).

(PR #429)

## 1.44.1 — 2026-10-13

  Closes #416
- **Problema**
  O procedimento documentado para sincronizar a branch de uma fatia atrasada com `main` (`git fetch origin main` + `git rebase origin/main` + push) é **estruturalmente incompatível com o modo automático**: rebase reescreve commits **já publicados**, o push seguinte exige `--force-with-lease`, e força-push é recusado pelo classificador de segurança ("Blocked by classifier") sem olhar o contexto — branch de fatia exclusiva da sessão, sem outro humano empurrando nela, dá no mesmo. Como o modo automático é o padrão para sessão longa, o pipeline mandava fazer justamente o que o ambiente em que ele mais roda recusa.
  Aconteceu na F-4 de `projeto-C/0001-fundacao-multi-tenant-e-acesso`: rebase limpo de 16 commits, push recusado, e a saída foi desfazer tudo (`git reset --hard origin/<branch>`) e refazer por `git merge origin/main` — que passou de primeira.
- **Mudança**
  Seção canônica nova em `docs/GIT-WORKFLOW.md`: **"Sincronizar a branch da fatia com `main`: `merge`, nunca `rebase`"**, colocada deliberadamente **ao lado** de "Reconciliação para a branch compartilhada da fatia" — porque a confusão entre as duas é o ponto:
  - **reconciliação com a branch compartilhada** (bloco existente): rebase de commits **locais ainda não publicados** sobre a ponta da branch; push é fast-forward, sem força. **Rebase continua certo ali.**
  - **sincronização com `main`** (bloco novo): a branch já está publicada; rebase reescreveria o que o remoto já tem. **Merge, push normal.**
  Três motivos, em ordem de peso:
  1. **Força-push é recusado pelo classificador do modo automático** — o caso acima.
  2. **Força-push sobre branch que vários agentes isolados tocaram já apagou trabalho revisado**, em silêncio, neste mesmo pipeline: dois commits aprovados descartados, sem erro visível, descobertos numa auditoria posterior (o caso já estava documentado no mesmo arquivo, no bloco logo abaixo). Merge não tem essa classe de falha.
  3. **Merge não invalida SHA gravado em artefato** — o campo `Commit` de `coverage/<fatia>-<trilha>.md` caduca depois de um rebase e obriga a recomputar; com merge continua válido sozinho.
  **E o histórico não perde nada**, que é a objeção óbvia: o PR da fatia entra em `main` por *squash merge* (regra 6), então a história interna da branch vira um commit único de qualquer forma — um commit de merge trivial tocando artefato de spec nunca chega a `main`. Rebase ali não compra legibilidade, só paga o risco.
- **Superfície**
  `docs/GIT-WORKFLOW.md` (seção canônica) e o passo **2b** das cinco skills de revisão (`code-review`, `ux-review`, `qa`, `security`, `sre`), que é onde a instrução de rebasear estava escrita. Mais duas menções que descreviam o sinal como "o rebase trouxe código novo de `main`" (`agents/code-reviewer.md`, área 9, e o passo 2b de `/sdd-code-review`): passam a nomear a **sincronização**, não a operação — o sinal para reconfirmar uma varredura de propagação é o mesmo, qualquer que seja o mecanismo.
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.44.0` → `1.44.1`.

(PR #427)

## 1.44.0 — 2026-10-13

  Closes #425
- **O que faltava**
  `docs/TESTING.md` decidia **o que** testar e em que nível (a pirâmide, com números medidos: 22 testes unitários custaram 0 s de suíte contra 36 s de 18 de integração). Não havia política de **como executar** pelo menor custo — cada agente improvisava, e os três custos que uma execução consome não estavam nomeados: tempo de parede, **tokens** (a saída da suíte entrando inteira no contexto) e **infraestrutura** (container recriado por arquivo, schema recriado por teste, minutos de runner multiplicados por sharding adotado sem medir).
- **Seção canônica nova**
  `docs/TESTING.md`, **"Custo de execução da suíte: tempo de parede, tokens e infraestrutura"** — cada alavanca vem com o seu limite, porque várias viram atalho silencioso se aplicadas na rodada errada:
  1. **Ordem e falha rápida** — camadas do mais barato para o mais caro; `-x`/`--fail-fast` só em rodada de **investigação**. **Nunca na rodada final de evidência**: parar na primeira falha esconde as demais e torna impossível dizer se o `N` de "falhas pré-existentes" mudou — justamente o sinal que o passo 5a dos agentes de implementação existe para pegar.
  2. **Paralelismo é declarado, nunca presumido** — o comando e **quais camadas são seguras** ficam em `docs/STACK.md`. Integração contra serviço **com estado** só é paralela com isolamento por execução: é a mesma classe de corrupção cruzada que um `migrate:fresh` já causou neste pipeline, produzindo erros que pareciam bug de produto.
  3. **Infraestrutura se reaproveita, não se recria** — container/emulador sobe **uma vez por execução** (não por arquivo); schema migra uma vez e cada teste reverte a própria transação; cache de dependências compartilhado entre worktrees e no CI; reuso de container entre execuções locais de TDD.
  4. **Tokens: a saída da suíte não entra inteira no contexto** — repórter condensado para o que o agente **lê**; saída completa salva em arquivo e pesquisada com `grep` (a cauda visível do terminal engana em suíte grande); **verde** → contagens e cobertura agregada; **vermelho** → nomes e mensagens só dos testes que falharam; nunca o relatório bruto como fonte.
  5. **Sharding em CI troca um custo por outro** — reduz tempo de parede e **multiplica minutos faturáveis** (N jobs pagam a subida de ambiente N vezes). Só com os dois eixos na mesa, como `docs/gates/sre.md` já exige: minutos × multiplicador do runner, não só relógio.
  **E o que nunca é cortado por economia**: a rodada final completa com cobertura, o gate de 80% por pacote, o comando de build/empacotamento real, e a lista nominal de falhas pré-existentes. "Economia" que apaga uma dessas quatro é gate desligado sem ninguém declarar.
- **Quem passa a ter o que fazer**
  - **`architect`, passo 2c** — registra em `docs/STACK.md` os campos que esta seção espera encontrar preenchidos: comando paralelo e camadas seguras, opção de falha rápida (marcada como de investigação), repórter condensado, escopo de fixture do serviço com estado e estratégia de reset, cache de dependências. Sem isso, cada agente improvisa o seu.
  - **`backend-developer`/`frontend-developer`** — ponteiro na regra de cobertura, com o resumo das alavancas aplicáveis à rodada final.
  - **`sre`** — item novo de cache de dependências no `ci.yml` e o alerta de custo do sharding.
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.43.0` → **`1.44.0`**.

(PR #426)

## 1.43.0 — 2026-10-13

  Closes #423
- **Problema**
  Nada no pipeline limitava o **escopo de uma spec**. O PRD podia cobrir uma feature de usuário ou um programa inteiro de trabalho, e o único mecanismo de quebra era a fatia vertical — que divide a *entrega*, não a *spec*.
  Spec grande sai caro de um jeito que **não aparece na medição de nenhuma etapa isolada**: todos os artefatos da spec crescem juntos e são relidos a cada etapa de cada fatia. `code-review.md`, `qa-report.md`, `security-review.md` e `sre-review.md` acumulam uma seção por fatia — histórico que, por regra, nunca é apagado; `timing-log.md` acumula uma linha por etapa por fatia; `coverage/` acumula um arquivo por fatia por trilha; PRD e TRD já nascem proporcionais ao escopo. O custo de contexto por etapa cresce com o tamanho da spec, e ela fica progressivamente mais lenta conforme avança — exatamente quando ainda resta mais trabalho.
- **Regra**
  **Uma spec é uma feature de usuário.** Pedido que reúne mais de uma vira uma **sequência numerada de specs**, decidida com o usuário antes de escrever o PRD. Sinais objetivos — nenhum isolado é corte duro, **dois ou mais juntos é caso de quebrar**:
  - mais de um **objetivo de usuário** distinto (várias telas do mesmo objetivo não contam);
  - a entrega em fatias verticais passaria de **~3 fatias**;
  - alguma fatia entregaria valor para uma **jornada diferente** das outras;
  - os critérios de aceite passariam de **~15 cenários**.
  A sequência preserva a ordem de valor: a spec `N+1` começa depois de a `N` fechar, igual ao que já vale entre fatias.
- **Onde ficou escrito**
  - **`.claude/agents/product-design.md`, passo 1b** — o critério e o porquê, antes de escrever qualquer coisa.
  - **`docs/gates/prd.md`** — item que **bloqueia** o PRD como spec única quando dois sinais se acumulam.
  - **`.claude/skills/sdd-prd/SKILL.md`, passo 2a** — a quebra é decidida com o usuário **antes de numerar a spec**, reservando os números da sequência inteira para a ordem ficar legível em `specs/` desde o começo.
  - **`specs/_template/prd.template.md`, seção 1** — o objetivo único desta spec e, quando houver, a sequência e a posição dela.
  - **`/create-project`** — ali a quebra é a **regra, não a exceção**: o pedido que cria um projeto do zero quase sempre reúne várias features, e um PRD inicial cobrindo o produto inteiro é o caminho mais rápido para uma spec que fica lenta já na terceira fatia.
  - **`CLAUDE.md`, regra 1b de governança** — a regra no resumo que toda sessão lê.
  Replicado em `plugins/btt-sdd/` (inclusive o scaffold e as duas cópias de `create-project`); `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.42.0` → **`1.43.0`**.

(PR #424)

## 1.42.0 — 2026-10-13

  Closes #421
- **Por quê**
  Cada etapa de revisão empurrava seu artefato antes de devolver o resultado, e cada push disparava um run completo de CI sobre um commit que, por construção, é **só Markdown em `specs/`**: não pode mudar comportamento, e o run não pode descobrir nada. Numa fatia medida, **~206 min de runner Windows (~412 faturáveis)** foram gastos exatamente assim. O `sre` já tem duas receitas para amortecer isso (cadência `ci-antes-do-merge`, short-circuit de docs-only), mas as duas mitigam um desperdício que o pipeline **cria**: o gatilho é o push por etapa, e isso é escolha nossa.
- **Protocolo**
  Seção canônica: `docs/GIT-WORKFLOW.md`, **"Push único por fatia: o CI roda uma vez, não uma vez por artefato de revisão"**.
  1. A trilha de implementação continua dando **um** push ao final — é esse que dispara o run de CI que de fato exercita código.
  2. Cada etapa de revisão **commita** o artefato e **não** dá push, informando no resultado a **branch e o SHA** do commit.
  3. Quem orquestra **integra na branch da fatia localmente** e confirma, **antes de remover o worktree**:
  ```bash
  git merge --ff-only <branch-informada-pelo-agente>
  git log -1 --format=%H -- specs/<slug>/<artefato>.md
  git worktree remove <caminho-do-worktree>
  ```
  4. **Um push ao final da cadeia de revisão da fatia**, pela última etapa que rodou nela — `/sdd-qa` em fatia intermediária, `/sdd-sre` na última fatia da spec (mesma lógica de quem tira o PR do draft).
  **Esse push final não precisa de run verde próprio**, e é daí que vem o saldo de 1 run por fatia em vez de 2: `docs/gates/merge.md` já aceita um run verde cujo `headSha` difere do `headRefOid` **quando se prova, com `git diff --stat`, que nada relevante ao workflow mudou entre os dois** — e um push que só acrescenta Markdown em `specs/` é exatamente essa prova. A prova continua sendo explícita, nunca presumida.
- **Exceções, todas por motivo real**
  - `sre` ajustou algo **fora de `specs/`/`docs/`** (`ci.yml`, `Dockerfile`, `infra/`) → push na hora e espera o CI: muda comportamento, precisa de run próprio.
  - **Rodada de correção** de achado → empurra e o CI roda; é o run que substitui o gate local.
  - **Escalonamento ao usuário** que vai ler o artefato no GitHub, ou trabalho que precisa atravessar para outra máquina/sessão.
  - **CI vermelho** no push final → rodada de correção normal, com o push dela. Um segundo run na fatia passa a ser o custo de um defeito real, não de um commit de Markdown.
- **O que não se perdeu**
  Os itens de gate que exigiam "commitado **e enviado (push)** pelo próprio agente" nasceram de artefato que não chegava à branch. Eles continuam exigindo durabilidade — **commit + integração na branch da fatia, com confirmação de alcançabilidade** —, só o meio mudou. O que se aceita está escrito: entre o commit e o push, o artefato existe só na máquina local; está commitado (recuperável), e o push fica no máximo uma etapa adiante — janela menor que a que o pipeline já aceita entre o primeiro commit de uma trilha e o push do final dela.
- **Superfície**
  `docs/GIT-WORKFLOW.md` (seção nova + regra 4 + tabela de mapeamento), `docs/gates/{code-review,ux,seguranca,qa,sre}.md`, os cinco agentes de revisão (`code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`) e as cinco skills correspondentes (passo de integração local; push único em `/sdd-qa` e `/sdd-sre`).
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.41.0` → **`1.42.0`**.
  > Nota: algumas linhas de prosa longas pré-existentes nos arquivos tocados foram re-wrapped para a largura padrão do repositório (~98 colunas) no mesmo commit — ruído cosmético no diff, sem mudança de conteúdo.

(PR #422)

## 1.41.0 — 2026-10-13

  Closes #419
- **Por quê**
  Três etapas de revisão por fatia, numa spec de N fatias, são **3N** invocações de agente — cada uma relendo PRD, TRD e artefatos só para se orientar. O custo dominante não é o tempo de parede: é o **contexto consumido**, que cresce com o tamanho da spec e torna o fluxo mais lento justamente nas specs grandes. Uma spec de 5 fatias passa de 15 rodadas dessas três etapas para 3, mais as antecipadas por critério objetivo.
- **Cadência nova**
  Seção canônica: `docs/SDD-WORKFLOW.md`, **"Cadência: o que roda por fatia e o que roda ao final da spec"** — os gates, as skills e os agentes apontam para lá em vez de repetir a regra.
  - **Por fatia**, sempre: 3 (implementação) → 4 (code review) → 5 (QA) → merge.
  - **Ao final da spec**, na última fatia pendente e antes do merge dela: 4b (UX), 6 (segurança), 7 (SRE), cada uma sobre o **diff acumulado da spec**. `docs/gates/sre.md` já exigia exatamente isso da fatia final — a mudança é tornar isso a regra das três, não a exceção da última.
  - **Antecipado por tarefa**: coluna nova **`Validação na fatia`** na decomposição de tarefas do TRD (`—` / `segurança` / `ux` / `sre`, combináveis), lida pelo orquestrador no fim do QA da fatia em vez de depender de memória.
  A antecipação **não é discricionária** quando a tarefa cai num critério que já é gate duro hoje:
  | Marca | Obrigatória quando a tarefa toca |
  |-------|------------------------------------|
  | `segurança` | autenticação, autorização, gestão de sessão, dado pessoal/sensível, ponto de entrada que aceita identificador externo (o mesmo critério objetivo de `gates/seguranca.md`) |
  | `sre` | `ci.yml`/`cd.yml`, `Dockerfile`/compose, `infra/terraform`, segredo ou variável de ambiente de deploy, campo que passa a ser obrigatório em rota ativa já consumida |
  | `ux` | fluxo ou tela **nova** exposta ao usuário final |
- **Dois efeitos colaterais tratados, não deixados cair**
  `/sdd-sre` carregava duas coisas que não são sobre infraestrutura e que desapareceriam das fatias intermediárias junto com a etapa 7:
  1. **`gh pr ready`** (passo 5d) — sem ele o PR fica bloqueado na UI do GitHub mesmo com `mergeable=MERGEABLE`;
  2. **retrospectiva da fatia** (passo 5c) — as issues de melhoria/aprendizado abertas em toda fatia aprovada.
  As duas passam para `/sdd-qa` (passo 7 novo), a última etapa por fatia. Na fatia final seguem com o `sre`, junto do acionamento do `tech-writer`.
- **O risco, escrito no próprio pipeline**
  Um defeito de segurança/UX/infra introduzido na fatia 1 de uma spec de 5 fatias chega a `main` e fica lá até o fim da spec. Está dito explicitamente no doc de cadência e em `gates/merge.md`, com o que limita o dano: o piso objetivo acima antecipa as classes de maior consequência; a revisão final cobre o **diff acumulado**, então nada escapa de revisão — só chega mais tarde; e o que ela achar já mergeado vira `/sdd-hotfix`, não merge revertido.
- **Superfície**
  `CLAUDE.md`, `docs/SDD-WORKFLOW.md`, `docs/GIT-WORKFLOW.md` (mapeamento + regra 4 do draft), `docs/QUALITY-GATES.md`, `docs/gates/{ux,seguranca,sre,qa,merge,trd}.md`, `.claude/agents/architect.md`, `specs/_template/trd.template.md` (coluna + tabela de critérios), e as skills `sdd-code-review` (roteamento), `sdd-qa` (passos 6 e 7), `sdd-ux-review`, `sdd-security`, `sdd-sre` (quando roda) e `sdd-status` (ausência dos três artefatos numa spec com fatia pendente deixa de ser lacuna).
  Replicado em `plugins/btt-sdd/` preservando as adaptações de namespace de cada cópia; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.13` → **`1.41.0`** (minor — muda a cadência do pipeline, não é só ajuste).

(PR #420)

## 1.40.13 — 2026-10-13

  Closes #415
- **Problema**
  O campo `Commit` do artefato de cobertura (`specs/<slug>/coverage/<fatia>-<trilha>.md`) era gravado, **nas duas trilhas**, como `git log -1 --format=%H -- src/ frontend/` — os dois caminhos juntos. A mesma expressão decidia o frescor em `code-reviewer` e `qa-engineer`.
  Efeito mecânico: uma rodada de correção que toca **só backend** movia o campo do artefato de **frontend** também. As etapas de revisão comparavam, viam "desatualizado", e reexecutavam a suíte completa de frontend **mais o comando de build/empacotamento** — as rodadas mais caras do pipeline (navegador real, empacotamento) — sem que uma linha de `frontend/` tivesse mudado. O inverso valia igual.
  É o mesmo defeito que a regra "nunca use `git rev-parse HEAD`" já existia para evitar, num eixo diferente: ali o metadado se movia por commit docs-only; aqui, por código de **outra** trilha. A cobertura já era **por pacote** (gate de 80% independente, explicitamente não uma média combinada) — o sinal de frescor não acompanhou.
- **Mudança**
  **Frescor por trilha** (`docs/TESTING.md`, novo bullet "O frescor é por trilha, nunca global" + os dois bullets vizinhos ajustados):
  - quem **grava**: `backend-developer` usa os caminhos de produção de backend (`src/` no layout padrão), `frontend-developer` os de frontend (`frontend/`), com os caminhos que `docs/STACK.md`/`docs/PROJECT-CONVENTIONS.md` documentarem quando o layout é outro;
  - quem **consome**: `code-reviewer` e `qa-engineer` decidem **cada trilha sozinha** — a trilha cujo `Commit` continua batendo não reexecuta suíte nem build, e quem roda regrava só o artefato da trilha que divergiu;
  - **caminho compartilhado** pelas duas trilhas (contrato gerado, pacote comum, esquema) entra na lista das duas: ali a reexecução cruzada está correta, porque o código que a trilha consome mudou de fato;
  - `specs/_template/coverage-summary.template.md` carrega a regra no cabeçalho, que é de onde o agente a lê na prática;
  - passo **`3a-bis`** de `.claude/skills/sdd-implement/SKILL.md`: a suíte completa local obrigatória de uma rodada de correção é a da **trilha afetada**, nunca a das duas.
  **Economia de runner sem perda de sinal** (`.claude/agents/sre.md`, área "CI", + item de gate em `docs/gates/sre.md`): `ci.yml` declara `concurrency` por workflow + ref com `cancel-in-progress` **fora da branch base**. O pipeline empurra vários pushes em sequência na mesma branch da fatia (código → rebase → artefato de cada etapa de revisão) e, sem isso, cada run antigo segue até o fim validando um SHA que ninguém vai mergear. Nenhum sinal se perde: o run mais novo cobre o mesmo código e o delta. Na branch base não se cancela — ali cada commit é um estado final com veredito próprio. Documentado junto: um run `cancelled` na lista não é achado quando existe run mais novo verde para o HEAD, e a adoção remove parte da amostragem acidental de flakiness (já documentada no `sre`), então vem com a proposta do amostrador deliberado.
  Replicado em `plugins/btt-sdd/` (incluindo o scaffold de `create-project`, preservando as adaptações de referência de cada cópia); `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.12` → `1.40.13`.

(PR #417)

## 1.40.12 — 2026-10-13

  Closes #409
- **Problema**
  O método padrão de verificação de isolamento multi-tenant é a mutação: alterar no código de produção a consulta que delimita o escopo, de forma que ela deixe de delimitá-lo, e confirmar que a suíte de isolamento pega a falha (ou que a política de row-level security sustenta sozinha, se a suíte continuar verde). Na Fatia F-3 de `projeto-C/0001-fundacao-multi-tenant-e-acesso` essa edição foi **recusada pelo classificador de segurança do ambiente em 3 tentativas seguidas** — a classe de mutação casa com um padrão reconhecido como perigoso, mesmo sendo parte de um teste que seria revertido antes do commit. O mesmo método havia funcionado em F-1 e F-2 da mesma spec.
  Sem a alternativa documentada, o risco é o agente **desistir da verificação** e aceitar o relato do QA sem medição própria — justamente numa área em que leitura do filtro não substitui medição.
- **Mudança**
  Área de revisão **9** nova em `.claude/agents/security-engineer.md`, registrando os dois métodos:
  1. **mutação** (padrão), revertida antes de qualquer commit, como qualquer mutação de teste;
  2. **equivalente sem tocar produção**, quando a edição é recusada pelo classificador: um teste de integração **temporário** que executa a consulta crua já sem a delimitação de escopo, contra o banco real em container, asseverando ali o que a mutação provaria — mesma evidência, arquivo de produção intocado, testes revertidos antes do push. Foi exatamente o contorno usado na rodada real.
  Com dois limites explícitos: não insistir numa 4ª tentativa (regra 2 de `docs/QUALITY-GATES.md`), e **não desistir da medição** — o relatório declara qual dos dois métodos foi usado e por quê, e um veredito de isolamento sem medição nenhuma nunca é apresentado como equivalente.
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.11` → `1.40.12`.
  > Nota de processo: a própria edição deste arquivo foi recusada pelo classificador na primeira tentativa, pela redação que descrevia a mutação — reescrita sem instrução removível de verificação, e aplicada via ferramenta de edição dedicada.

(PR #414)

## 1.40.11 — 2026-10-13

  Closes #408
- **Problema**
  O pipeline já tinha a regra num sentido — passo 6b de `sdd-ux-review`: correção de achado de UX que toca código de produção volta para `/sdd-code-review` escopado ao delta, porque é o `code-reviewer` quem sabe avaliar código. Faltava a **simétrica**: quando a correção de um achado levantado **pela 4b** é reverificada só tecnicamente (código + testes) pelo `code-reviewer`, nada no pipeline exigia que a própria UX reconfirmasse, do ângulo de usabilidade, que a correção resolve o que ela apontou.
  Sem essa simetria, um achado bloqueante de usabilidade pode ser formalmente fechado **só com evidência técnica** — exatamente o tipo de lacuna que a etapa 4b existe para evitar. Já aconteceu na fatia F-3 de `projeto-C/0001-fundacao-multi-tenant-e-acesso`: achado bloqueante de navegação (edição pendente descartada em silêncio), corrigido com `useBlocker`, reverificado por uma rodada escopada de code review, e o pipeline seguiu direto para `/sdd-qa`. `code-review.md` chegou a atribuir a aprovação a uma seção de `ux-review.md` que **não existia**. Foi o `qa-engineer` — não o orquestrador — que conferiu via `git log` e registrou a lacuna como achado de processo, forçando uma rodada extra fora do fluxo.
- **Mudança**
  - **`.claude/skills/sdd-ux-review/SKILL.md`**, passo `6c` (ao lado do `6b` existente): achado desta etapa só fecha com reconfirmação desta etapa. Depois da rodada técnica, o retorno antes de `/sdd-qa` é uma rodada de `/sdd-ux-review` **escopada ao achado** (não uma revisão completa nova das 7 áreas), que acrescenta a `ux-review.md` uma seção de reverificação nomeando o achado, o método e a evidência.
  - **`.claude/skills/sdd-code-review/SKILL.md`**, passo `5b`: o roteamento do lado de quem reverifica — se a rodada foi escopada ao delta de uma correção de achado da 4b, a próxima etapa é `/sdd-ux-review`, não `/sdd-qa`. É onde o orquestrador de fato decide o próximo passo, então é onde a regra precisa estar escrita.
  - **`docs/gates/ux.md`**: item de gate bloqueante — nenhum achado desta etapa fica fechado só com evidência técnica.
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.10` → `1.40.11`.

(PR #413)

## 1.40.10 — 2026-10-13

  Closes #407
- **Problema**
  O padrão de envelope único de resposta de erro (comum a projetos que seguem a orientação de "um único produtor de resposta de erro") costuma ter um mapeador que traduz issues do validador de esquema para `fields: [{ path, code }]`, contra um **enum fechado** de códigos conhecidos. Quando uma issue não tem código reconhecido no enum, o mapeador a descarta em silêncio — e se for a única issue, o resultado é um `422 validation_failed` com `fields: []`: nenhuma pista de qual campo falhou.
  O risco é estrutural, não descuido. Um esquema que não cobre uma forma de rejeição (um campo `.optional()` sem o `.nullable()` correspondente, recebendo `null`) **não** quebra a compilação e **não** reprova nenhum teste — só produz silenciosamente uma resposta inútil para depuração. Na fatia F-2 de `projeto-C/0001-fundacao-multi-tenant-e-acesso` isso custou uma rodada de correção inteira: duas hipóteses plausíveis (CNPJ, CEP) descartadas por leitura de código antes de alguém capturar o corpo real da resposta e rastrear o `error-mapper.ts`.
- **Mudança**
  - **`.claude/agents/backend-developer.md`** (seção "Regras inegociáveis de código", regra 6, irmã da regra 5 sobre "resultado vazio esperado"): generaliza o padrão para qualquer mapeador entre vocabulário **aberto** (issues de validador de esquema, códigos de driver de banco, erros de SDK externo) e vocabulário **fechado** do projeto. O caso não-mapeado tem destino explícito, e nunca é "ignorar" — log do identificador bruto (`path`/código interno, nunca a mensagem crua ao cliente), código de fallback na saída, e teste dedicado para a entrada que o enum **não** conhece. Mais o docblock do mapeador dizendo qual é o comportamento do caso não-mapeado, para quem acrescentar um campo novo ao contrato depois.
  - **`docs/gates/code-review.md`**: item de gate correspondente, **bloqueante** quando a resposta pode sair sem pista alguma — é o `code-reviewer` que pega isso antes do merge.
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.9` → `1.40.10`.

(PR #412)

## 1.40.9 — 2026-10-13

  Closes #406
- **Problema**
  Na fatia F-2 de `projeto-C/0001-fundacao-multi-tenant-e-acesso`, dois achados do CI real passaram por uma rodada de correção **errada** (plausível, mas sem efeito medido) antes de uma segunda rodada achar a causa. Nos dois casos a primeira tentativa partiu de uma representação **indireta** do problema:
  - **overflow de 360px** — corrigido por leitura da árvore de acessibilidade do Playwright, que mostra **estrutura**, não **geometria**; a causa real (`.acoes` sem `flex-wrap`) só apareceu ao instrumentar `getBoundingClientRect()`/`scrollWidth` no navegador. O agente mediu "0 overflow local" antes e depois da mudança — o sinal já estava lá, e só foi tratado como sinal depois do CI repetir os mesmos pixels exatos;
  - **`422` genérico no `PUT /api/space/profile`** — duas hipóteses descartadas por leitura de VO antes de alguém capturar o corpo real da resposta e ver `fields: []`, a pista que levou à causa (um sub-campo `.optional()` recebendo `null`).
  O custo da evidência direta é uma linha de código; o da correção baseada em hipótese errada é a rodada inteira.
- **Mudança**
  - **`.claude/agents/backend-developer.md` e `.claude/agents/frontend-developer.md`** (seção "Regras inegociáveis de código"): bloco novo definindo erro opaco (`422` sem detalhe, geometria que não bate, falha genérica de e2e) e exigindo medição direta do fenômeno **antes** da hipótese — corpo real da resposta capturado da rede, geometria real avaliada no navegador. Inclui os dois limites que faltavam: **correção que não move a medição não é a correção**, e o relatório diz **qual medição confirmou a causa** (eliminação de hipóteses por leitura de código estreita a busca, não fecha causa).
  - **`.claude/skills/sdd-implement/SKILL.md`**, seção "Retomando para corrigir achados de revisão": passo `3e` — quem **pede** a correção inclui a medição direta no pedido e a cobra como critério de aceite, em vez de esperar que o agente lembre.
  Replicado em `plugins/btt-sdd/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.8` → `1.40.9`.

(PR #411)

## 1.40.8 — 2026-10-13

  Closes #405
- **Problema**
  Comando de cobertura que termina com os testes rodando normalmente, mas **sem imprimir nenhuma tabela de cobertura e sem criar o diretório de relatório** — nenhum erro, nenhum aviso. O sintoma (silêncio total) se confunde com "o comando não terminou" ou "o ambiente está quebrado", e pode custar uma investigação cega.
  A causa é a opção `coverage.reportOnFailure` do `@vitest/coverage-v8`, cujo padrão é `false`: com qualquer teste vermelho na execução, o provedor não escreve nem o resumo no console nem os arquivos. O padrão de um relatório só para várias suítes reunidas numa execução (`test.projects` ou equivalente) é exatamente onde morde — numa fatia grande é comum ter uma falha pontual e alheia à trilha enquanto se quer medir a cobertura.
- **Mudança**
  Nova seção `### Armadilha conhecida: comando de cobertura que termina sem relatório nenhum` em `docs/TESTING.md`, junto ao gate de cobertura de 80% (mesmo padrão da armadilha já documentada sobre `testPathIgnorePatterns` do Jest). Escrita agnóstica de stack, com o caso vitest/v8 nomeado como instância concreta, e com dois limites explícitos:
  - como confirmar a hipótese em **um comando** (`--coverage.reportOnFailure=true`, ou a opção equivalente da stack) antes de investigar o ambiente;
  - **não ligar isso por padrão** — cobertura medida sobre suíte com teste vermelho é enganosa, e o campo `Commit` do artefato de cobertura só vale com a suíte verde.
  Replicado em `plugins/btt-sdd/docs/TESTING.md`; `scripts/check-plugin-sync.py` verde. Versão do plugin: `1.40.7` → `1.40.8`.

(PR #410)

## 1.40.7 — 2026-10-12

  Closes #402
- **Problema**
  Na fatia F-1 (2º PR) de `projeto-C/0001-fundacao-multi-tenant-e-acesso`, a tarefa que devolvia o job `navegador` ao CI precisou de duas rodadas. Na primeira, o `backend-developer` acrescentou um passo no `ci.yml` exportando uma variável de URL base para `$GITHUB_ENV`, pensando apenas no consumidor que motivou a mudança — que **não** lê essa variável.
  Outro arquivo tinha um mecanismo de override manual não documentado como "nunca usar em CI", com fallback silencioso (`process.env.X ?? PADRÃO`). Exportar a variável job-wide desviou **toda a suíte de outra história de usuário** — nada relacionado à mudança — para um caminho de rede diferente: ~80 falhas de `502 Bad Gateway`, descobertas só no primeiro run real do job. Nenhuma validação local pegava, porque o mecanismo de override só importa dentro do CI.
  Variável exportada para `$GITHUB_ENV` vale para todos os passos seguintes do job. Ela não é escopada ao consumidor que motivou a exportação, e qualquer leitor do mesmo nome com fallback silencioso muda de comportamento sem erro e sem aviso.
- **O que muda**
  Novo bullet em `docs/gates/governanca.md`: antes de exportar uma variável de ambiente com escopo amplo (`$GITHUB_ENV` ou equivalente), grepar o **nome exato** em todo o pacote que o job executa e auditar **todo** leitor — não só quem precisa dela. Com o alerta específico sobre o leitor de fallback silencioso, que é o que falha sem sinal.
  **Por que no gate transversal e não nos dois agentes**: `backend-developer` e `sre` podem ambos tocar o `ci.yml`, e os únicos arquivos de `docs/gates/` que os dois declaram são os três transversais (`governanca`, `licoes`, `escrita`). Descrever o mesmo mecanismo nos dois agentes criaria exatamente a duplicação que o próprio `governanca.md` manda evitar.
  Ficou imediatamente depois do bullet de "nenhum consumidor" (#396): é o mesmo eixo na direção inversa — um proíbe concluir que ninguém lê um nome com busca parcial, o outro proíbe ampliar o escopo de um nome sem auditar quem o lê.
  Replicado em `plugins/btt-sdd/docs/gates/governanca.md`; `scripts/check-plugin-sync.py` verde. Versão do plugin: 1.40.6 → 1.40.7.

(PR #404)

## 1.40.6 — 2026-10-12

  Closes #401
- **Problema**
  Na fatia F-1 (2º PR) de `projeto-C/0001-fundacao-multi-tenant-e-acesso`, **sete de sete** invocações com `isolation: "worktree"` relataram que o worktree isolado nasceu com a branch local já desatualizada contra a remota — em alguns casos ~30 commits atrás. As duas trilhas de implementação (`backend-developer`, `frontend-developer`) e as cinco etapas de revisão (`code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`).
  Nenhum dos sete tinha sido instruído a checar isso. Cada um gastou tempo e tokens próprios fazendo `fetch` + `reset --hard`/`rebase` antes de poder começar. Sete de sete não é acaso: é o comportamento padrão do mecanismo quando reaproveita um worktree de uma invocação anterior em vez de criar um novo a partir do `HEAD` atual.
  O custo visível é o desperdício repetido. O risco invisível é pior — um agente que *não* checasse revisaria ou implementaria sobre a base errada, sem nada avisar até o push divergir.
- **O que muda**
  **Regra canônica** em `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes": todo agente que recebe um worktree isolado sincroniza contra a ponta remota **antes de qualquer leitura ou trabalho** — `git fetch` + `git status -sb` + `reset --hard origin/<branch>`, com a ressalva de usar `rebase` quando já houver commit local próprio.
  **Ponteiro curto** em `docs/AGENT-PREAMBLE.md`, que todos os 11 agentes leem antes de começar — em vez de repetir o mecanismo nas 6 skills (`implement`, `code-review`, `ux-review`, `qa`, `security`, `sre`), o que contrariaria a própria regra de `docs/gates/governanca.md` sobre descrever um mecanismo em vários lugares.
- **Sobre a sugestão 1 da issue**
  Fazer o mecanismo de `isolation: "worktree"` sincronizar sozinho ao reaproveitar um worktree é comportamento do harness do Claude Code — **fora do controle deste repositório**. Aplicada só a sugestão 2, que é autossuficiente.
  Replicado em `plugins/btt-sdd/docs/`; `scripts/check-plugin-sync.py` verde. Versão do plugin: 1.40.5 → 1.40.6.

(PR #403)

## 1.40.5 — 2026-10-12

  Closes #397
- **Problema**
  `agents/architect.md` já tem a regra de que a coluna "Depende de" nunca pode ser `nenhuma` quando uma tarefa mede o comportamento da plataforma contra artefato produzido por outra tarefa da mesma fatia. Mas o texto e os dois exemplos dessa regra estão todos enquadrados em **tarefa de investigação** (`[medido]`, perguntas de medição).
  Tarefa de e2e/integração que exercita código de outra tarefa da mesma fatia é logicamente o mesmo caso — e caiu fora do radar do `architect` **duas vezes na mesma fatia** (T-16 dependendo de T-13, e antes disso T-9). Nas duas vezes foi a leitura manual do orquestrador, antes de montar o plano da rodada, que pegou a lacuna. Nenhum gate automático e nenhuma regra do `architect` pegaria.
- **O que muda**
  No mesmo trecho que distingue as duas classes de tarefa `[medido]`, o critério passa a dizer explicitamente que vale também para tarefa de e2e ou de integração que exercita código de outra tarefa da fatia. Com exemplo direto: uma tarefa de e2e que testa rotas HTTP depende de cada tarefa que implementa uma dessas rotas; numa fatia de UI, a tarefa que bate contra o backend depende das tarefas que expõem as rotas chamadas.
  E o ponto que fecha a lacuna: "parece óbvio" não é dependência declarada — quem monta o plano da rodada lê a coluna, não a intenção.
  Replicado em `plugins/btt-sdd/agents/architect.md`; `scripts/check-plugin-sync.py` verde. Versão do plugin: 1.40.4 → 1.40.5.

(PR #400)

## 1.40.4 — 2026-10-12

  Closes #396
- **Problema**
  Duas vezes na mesma fatia, uma conclusão sobre privilégio de banco de dados foi tirada de um `grep` pela sintaxe do query builder (`deleteFrom(`) — que não enxerga a mesma operação escrita como SQL cru via template literal.
  O `architect` escreveu uma premissa de "risco nulo" num TRD a partir dessa busca. Um segundo agente (o orquestrador) repassou a premissa ao usuário sem reverificação independente. Só depois `grep -rni 'delete from'` achou os dois adapters que apagavam pela forma crua.
  É um ponto cego estrutural, não um descuido pontual: qualquer projeto que use um builder SQL **e** permita SQL cru para o que o builder não cobre bem repete a mesma classe de erro. O risco é maior justamente em revisão de arquitetura e de segurança, onde "nenhum consumidor" é o que costuma justificar revogar um privilégio — sem rede.
- **O que muda**
  Novo bullet em `docs/gates/governanca.md` (gate transversal, vale para todas as etapas): antes de concluir "nenhum consumidor"/"nenhum uso" de uma operação, listar as formas em que ela pode estar escrita neste projeto e buscar cada uma, case-insensitive. Query builder vs. consulta crua é o caso mais comum, mas a regra cobre também update, insert, concessão de privilégio e nome de símbolo montado em tempo de execução.
  Redigido agnóstico de stack — Kysely entra como exemplo, não como premissa.
  Replicado em `plugins/btt-sdd/docs/gates/governanca.md`; `scripts/check-plugin-sync.py` verde. Versão do plugin: 1.40.3 → 1.40.4.

(PR #399)

## 1.40.3 — 2026-10-12

  Closes #395
- **Problema**
  Numa fatia real, o `sre` acrescentou um job novo ao `.github/workflows/ci.yml` (auditoria de dependências) — decisão legítima e registrada. O projeto tinha um teste de arquitetura que enumera os nomes de job esperados do `ci.yml` por **igualdade exata**, e o `sre` não sabia que esse teste existia. O CI ficou vermelho, e a correção foi puramente mecânica: acrescentar o nome do job à lista literal.
  Não foi a primeira vez na mesma fatia que esse tipo de teste de guarda custou uma rodada extra. É um problema de descoberta, não de julgamento.
- **O que muda**
  Novo bullet na área 1 (CI) de `agents/sre.md`: ao adicionar ou renomear um job no `ci.yml`, procurar por um teste que enumere nomes de job por igualdade exata (`JOBS_ESPERADOS` ou padrão equivalente, em `tests/architecture/` e nos testes de configuração) e atualizá-lo na mesma rodada — antes de empurrar o commit, não depois do CI acusar vermelho.
  Replicado em `plugins/btt-sdd/agents/sre.md`; `scripts/check-plugin-sync.py` verde. Versão do plugin: 1.40.2 → 1.40.3.

(PR #398)

## 1.40.2 — 2026-10-11

- **Decisão**
  Issue #393 oferecia três saídas; a escolhida foi **recalibrar os números para português**,
  preservando a razão do padrão (procedimento mais apertado que descritivo):
  | | Antes (STE, inglês) | Agora (adaptado) |
  |---|---|---|
  | Texto de procedimento | 20 palavras | **25** |
  | Texto descritivo | 25 palavras | **30** |
- **Por quê**
  Nas três primeiras mudanças deste repositório sob o gate (#387, #389, #390), o item reprovou a
  primeira redação em **todas** — uma delas com oito frases estouradas de uma só vez —, sempre em
  prosa escrita no estilo que o repositório já usava antes do gate existir. A #390 exigiu até reflow
  de blocos inteiros, porque dividir uma frase muda a quebra de linha do parágrafo todo.
  A causa é o idioma, não a redação. Português gasta mais palavras funcionais para o mesmo conteúdo:
  artigos onde o inglês dispensa, preposições onde ele compõe substantivos, locuções onde ele tem
  verbo único ("depois de" por *after*, "a partir de" por *from*). Com 20, o item passava a reprovar
  frases de **uma** ideia só, e a correção virava divisão artificial — duas frases curtas que o leitor
  recompõe na cabeça. O limite existe para servir à regra 1 ("uma ideia por frase"); quando aperta mais
  que ela, mede outra coisa.
- **O que mudou**
  - **`docs/WRITING-STYLE.md`, regra 2** — os números novos, e o registro explícito de que **divergem
  do padrão por decisão deliberada de adaptação ao idioma**, com o motivo e a evidência medida. Essa
  parte não é cosmética: o doc apresentava 20/25 como "os limites da STE", e um número diferente sem
  explicação pareceria erro de transcrição (era a ressalva que a própria issue #393 pedia).
  - **`docs/WRITING-STYLE.md`, ressalva 1** — ganha o ponteiro de que o limite de palavras é o **único
  valor** que a adaptação muda; o resto das regras vale em qualquer idioma como está.
  - **`docs/gates/escrita.md`** — limites novos, citando a regra 2 em vez de repetir a justificativa.
  O que **não** mudou: "uma ideia por frase" continua sendo o item que importa, e a contagem continua
  sendo o último recurso para detectá-lo.
- **Verificação**
  Os dois arquivos passam nos limites novos, conferidos com a mesma contagem que o gate descreve
  (código inline entre backticks conta como uma palavra). Nenhuma linha nova acima de 100 colunas.
  Replicado em `plugins/btt-sdd/` (2 docs); `check-plugin-sync.py` com **62 pares em dia**. Versão
  `1.40.1` → `1.40.2` (recalibração, não capacidade nova).
  Closes #393

(PR #394)

## 1.40.1 — 2026-10-10

- **Problema (issue #390)**
  O passo **1b** dos agentes de implementação mandava editar a coluna Status do TRD para `em
  andamento` *in-place*. O passo **5** do mesmo arquivo já tinha a regra oposta para o outro extremo
  do ciclo, e com o motivo escrito:
  > **não edite a coluna Status do TRD para `implementado` aqui** — duas trilhas terminando em
  > paralelo e editando a mesma tabela na última task já causou um conflito mecânico real de merge.
  **O mesmo raciocínio vale para `em andamento`**, e o 1b não o aplicava. Numa fatia full-stack —
  o caso normal — as duas trilhas são despachadas juntas e editariam a mesma coluna da mesma tabela no
  mesmo minuto.
  Na prática o orquestrador percebia e desativava o 1b no prompt ("não edite a coluna Status da seção
  13 — eu promovo"), deixando o agente com uma contradição entre o próprio arquivo de definição e a
  invocação. A invocação seguinte recomeçava do mesmo impasse, porque a assimetria seguia no arquivo —
  e depender do orquestrador lembrar é depender do canal que `docs/gates/governanca.md` descreve como
  "o mais caro e o mais frágil".
- **O que mudou**
  A regra fica simétrica e **sem condição**, igual ao passo 5: o implementador **nunca** edita a
  coluna Status; só comenta a transição na Issue GitHub da própria tarefa, que é por trilha e por isso
  não colide.
  | Transição | Quem grava | Onde |
  |---|---|---|
  | `em andamento` (despacho) | orquestrador | `/sdd-implement`, passo 4e (**novo**) |
  | `em andamento` (retomada, saindo de `bloqueado`) | orquestrador | `/sdd-implement`, passo 2b da seção de retomada (**novo**) |
  | `implementado` | orquestrador | `/sdd-implement`, passo 5 (já existia) |
  A transição da **retomada** não existia em nenhum dos dois lados da proposta original — sem ela,
  `bloqueado` → `em andamento` ficaria órfã ao sair do 1b.
  **Escolhi sem condição** em vez do "só quando a fatia tem duas trilhas" que a issue sugeria: regra
  condicional depende de o agente saber se a outra trilha existe, e é o tipo de condição que se aplica
  errado. Para trilha única o orquestrador não paga nada por fazer sempre.
- **Dois achados colaterais, consertados aqui**
  - **O bullet de `docs/gates/status-de-tarefas.md` tinha as *duas* metades desatualizadas** — ele
  ainda atribuía `implementado` aos implementadores, contrariando o passo 5 desde antes desta issue.
  As duas foram corrigidas na mesma passada.
  - **O passo 5b dos dois agentes** citava "a transição para `em andamento` na coluna Status do TRD"
  como um dos arquivos a conferir contra `origin/<branch>` depois do push. Com o 1b mudado, o agente
  não produz mais esse commit — o exemplo foi trocado pelo que ele de fato commita.
- **Verificação**
  Os trechos novos passam no **gate de escrita** (`docs/gates/escrita.md`): frases divididas e blocos
  reflowados para ≤100 colunas antes do commit. Replicado em `plugins/btt-sdd/` (2 agentes + 1 skill +
  1 gate); `check-plugin-sync.py` com **62 pares em dia**. Versão `1.40.0` → `1.40.1`.
  Closes #390

(PR #392)

## 1.40.0 — 2026-10-10

- **Problema (issue #389)**
  Uma fatia vertical pode cortar a cadeia que o **próprio roteiro demonstrável dela** precisa. O caso
  real tinha o harness de browser disponível, então a cláusula existente sobre "projeto sem harness de
  browser real" não se aplicava — o que faltava era outra coisa:
  - o roteiro começava por uma **sessão de administração**;
  - a credencial nascia por CLI, **não ativada**, com token de definição de senha por e-mail;
  - a rota que consome esse token, e a tela correspondente, estavam na fatia **seguinte**, por decisão
  de recorte.
  Medido contra a pilha real: o link do e-mail caía no coringa do roteador (token descartado) e a rota
  de conclusão respondia 404 — com um teste unitário da própria fatia **assegurando** que ela ficasse
  ausente.
  A fatia era internamente consistente, cada tarefa cumpria sua célula, e o roteiro demonstrável dela
  era **inalcançável por construção**. Isso é invisível para toda revisão que confere código contra
  TRD, porque o TRD é a fonte do recorte. As asserções de completude que os TRDs já têm cobram "toda
  permissão declarada tem rota" e "toda rota tem handler"; nenhuma cobra que **o primeiro passo do
  roteiro desta fatia tenha porta de entrada nesta fatia**.
  O agente de implementação fez o certo — não inventou rota, não publicou rota da fatia posterior, não
  semeou credencial por SQL, cobriu o alcançável e escalou. Mas o custo apareceu no meio da fatia, com
  o ambiente já de pé.
- **O que mudou**
  **`.claude/agents/architect.md`, passo 8b** (vizinho da cláusula que já trata "e2e sem harness de
  browser, distinto dela: lá a pergunta é se o projeto tem harness; aqui é se o roteiro tem **início
  alcançável**). Percorra o roteiro do primeiro passo para trás, liste o que ele pressupõe, e confirme
  que cada pré-condição tem produtor publicado **nesta** fatia. Quando o produtor está numa fatia
  posterior, a saída é decidida no TRD — nunca deixada para quem implementa descobrir no meio:
  1. trazer o produtor mínimo para esta fatia;
  2. dar ao ferramental de provisionamento um modo que dispense a tela ausente;
  3. declarar na célula da tarefa que o e2e cobre só o alcançável, nomeando o que fica de fora.
  **`docs/gates/trd.md`** cobra a confirmação na aprovação do TRD, com a razão de por que nenhuma das
  outras asserções de completude a substitui.
  É a mesma classe que um TRD real já registrou para o **caminho de escrita** ("a rota que declarava a
  história era inalcançável por construção"), agora no **caminho de entrada**. E é barato para o
  `architect`: ele relê o roteiro que ele mesmo acabou de escrever.
- **Verificação**
  Os trechos novos passam no **gate de escrita** (`docs/gates/escrita.md`): a primeira redação estourou
  o limite de 20 palavras em **oito** frases, todas divididas antes do commit.
  Replicado em `plugins/btt-sdd/` (1 agente + 1 gate); `check-plugin-sync.py` com **62 pares em dia**.
  Versão `1.39.1` → `1.40.0` — verificação nova exigida no TRD, não só ajuste de texto.
  Closes #389

(PR #391)

## 1.39.1 — 2026-10-09

- **Problema (issue #387)**
  A ordem prescrita invalidava o próprio campo que o passo 5 existe para manter correto:
  1. passo 5 — rode a suíte e **grave** `specs/<slug>/coverage/<fatia>-<trilha>.md`, com `Commit`
  recebendo `git log -1 --format=%H -- src/ frontend/`;
  2. depois — `git fetch` + `git rebase origin/<branch>` + `git push`
  (`docs/GIT-WORKFLOW.md`, "Reconciliação para a branch compartilhada da fatia").
  O rebase reescreve os SHAs de todos os commits locais, inclusive o que o artefato acabou de
  referenciar. O campo `Commit` passava a apontar para um objeto que não existe mais na branch
  publicada — **o mesmo sintoma que o passo 5 já descrevia** ("um `Commit` apontando para um SHA que
  não bate faz quem comparar literalmente concluir 'desatualizado' e reexecutar a suíte à toa"),
  produzido pela ordem das instruções em vez de por descuido.
  A exceção irmã que já existia ("se o commit adicional é só documentação, não toque no artefato")
  cobre um commit **novo** depois do artefato. Não cobre um **rebase**, que mexe no SHA do commit já
  gravado.
- **Correção**
  **Na raiz, como a issue preferiu** (opção 1): a ordem passa a ser rode a suíte → `fetch`+`rebase` →
  grave o artefato com o SHA final → publique. Não acrescenta nenhuma verificação ao caminho feliz.
  **Mais a rede para o buraco residual que a ordem sozinha deixa**: se o `push` for rejeitado, um
  segundo `fetch`+`rebase` é necessário e o campo caduca de novo. Nesse caso o agente recomputa o
  campo antes de republicar e decide, no mesmo momento, se a suíte roda outra vez — se o que o rebase
  trouxe não toca código (`git diff --stat <base>..HEAD -- src/ frontend/ tests/` vazio), só o SHA
  muda; se toca, a suíte roda de novo. Era a opção 2 da issue, aqui como complemento da 1 em vez de
  alternativa a ela.
- **Onde**
  - passo 5 de `.claude/agents/backend-developer.md` e `.claude/agents/frontend-developer.md` — a
  ordem e o motivo mecânico;
  - `docs/GIT-WORKFLOW.md`, seção "Reconciliação para a branch compartilhada da fatia" — a regra geral
  ("o rebase invalida todo SHA de commit já gravado dentro de um artefato"), as duas obrigações, e o
  incidente registrado: o rebase trouxe um commit docs-only, os números continuavam válidos e bastou
  corrigir o SHA — mas só porque o agente conferiu por iniciativa própria;
  - `docs/gates/implementacao.md` — o bullet do artefato de cobertura passa a exigir SHA que existe de
  fato na branch publicada.
- **Verificação**
  Os trechos novos passam no **gate de escrita** que entrou na 1.39.0 (`docs/gates/escrita.md`):
  várias frases minhas estouraram o limite de 20 palavras na primeira redação e foram divididas antes
  do commit. Primeira vez que o gate rodou contra uma mudança deste repositório — e pegou.
  Replicado em `plugins/btt-sdd/` (2 agentes + 2 docs); `check-plugin-sync.py` com **62 pares em
  dia**. Versão `1.39.0` → `1.39.1` (correção, não capacidade nova).
  Closes #387

(PR #388)

## 1.39.0 — 2026-10-09

- **Problema (issue #385)**
  O pipeline definia com rigor **o que** cada artefato contém — gates por etapa, templates, critérios
  de aprovação — e nada sobre **como a prosa é escrita**. Antes deste PR, o repositório inteiro não
  tinha um único resultado para "voz ativa", "frases curtas" ou "glossário".
  Num pipeline cuja mecânica inteira é um artefato alimentando o próximo (o TRD é lido por quem
  implementa; o relatório de revisão, pela etapa seguinte), frase ambígua não custa uma correção de
  texto — custa retrabalho duas etapas adiante, por reinterpretação.
- **O que mudou**
  **`docs/WRITING-STYLE.md`** (novo) adota o conjunto de regras da **ASD-STE100** (Simplified
  Technical English) aplicado ao idioma em que o artefato já é escrito: uma ideia por frase, limite de
  20 palavras em procedimento e 25 em texto descritivo, voz ativa, tempo simples, um termo por
  conceito, procedimento em imperativo numerado, sem estilo telegráfico, verbo em vez de
  nominalização, sem negação dupla. Os itens de julgamento (ordem da informação, quando uma lista
  substitui prosa) ficam separados, como orientação que não bloqueia.
  Duas ressalvas estão escritas no próprio doc, porque as duas mudam o que a adoção significa:
  1. **O dicionário controlado do padrão não é reproduzido aqui.** É material licenciado da ASD e não
  tem equivalente direto em português. O papel funcional dele passa a ser cumprido por
  **`docs/GLOSSARY.md`** — condicional, mesmo padrão de ausência-por-padrão de `BASELINE.md`:
  nasce na primeira colisão de termo confirmada (um conceito com dois nomes, ou um nome para dois
  conceitos), qualquer agente acrescenta entrada, o `tech-writer` consolida. O nome rejeitado fica
  registrado de propósito: é por ele que a próxima busca encontra o termo certo.
  2. **O limite é por frase, nunca por conteúdo.** Aplicada ingenuamente, a STE apagaria justamente o
  que dá autoridade aos documentos deste pipeline: a narrativa de incidente concreto ("já aconteceu
  de verdade: ...") que explica por que uma regra existe. Frase longa se **divide**; fato nunca se
  apaga. Isso é um item do gate, não uma nota de rodapé.
  **`docs/gates/escrita.md`** (novo) é o **terceiro gate transversal**, ao lado de `governanca` e
  `licoes`, só com os itens verificáveis. Um achado desta classe precisa citar qual item da lista o
  sustenta — os itens de julgamento nunca sustentam achado, para não travar artefato por gosto de
  redação.
  Ligações concretas:
  - os **10 agentes** que declaram lista de gates passam a carregá-lo (contagem, lista e a frase de
  "quantos são transversais" ajustadas em cada um);
  - o **`tech-writer`**, que não tinha lista de gates, ganha os dois transversais que valem para ele —
  e o papel explícito de consolidar o glossário;
  - **`docs/gates/code-review.md`** ganha um item para a prosa dentro do código, que é território
  daquela etapa: o nome do conceito no comentário é o mesmo nome no código e no TRD.
- **Escopo (decidido com o usuário)**
  Cobre artefatos de `specs/` (PRD, TRD, relatórios de revisão), `docs/`/`README.md`/`docs/adr/`, e
  comentários/docstrings de código. **Não** cobre mensagem de commit, corpo de PR nem corpo de issue —
  exclusão deliberada e registrada: esses textos têm convenção própria (`docs/GIT-WORKFLOW.md`) e são
  lidos no contexto do diff, não são a cadeia de artefatos que uma etapa seguinte executa.
- **Verificação**
  Os dois arquivos novos **passam no próprio gate** — nenhuma frase acima do limite, conferido com a
  regra que eles mesmos definem (código inline conta como uma palavra). Várias frases minhas falharam
  na primeira redação e foram divididas.
  Replicado em `plugins/btt-sdd/` (2 docs novos, 4 docs de governança, 11 agentes); `WRITING-STYLE`
  registrado na normalização de `scripts/check-plugin-sync.py`, que passa com **62 pares em dia**.
  Versão `1.38.0` → `1.39.0` (capacidade nova).
  Closes #385

(PR #386)

## 1.38.0 — 2026-10-09

- **Problema (issue #383)**
  Todo subagente que este pipeline invoca rodava no **mesmo modelo** — o padrão da sessão. Não havia
  nenhuma instrução, em nenhum agente, skill ou doc, sobre escolher um modelo mais barato para a
  parcela do trabalho que é mecanicamente bem definida.
  Os dois usos de subagente têm perfis de custo **opostos**:
  | | Etapa com veredito | Sub-tarefa auxiliar bem definida |
  |---|---|---|
  | Produz | artefato aprovável, veredito de gate, código de produção | conclusão destilada, em formato definido antes de invocar |
  | Erro custa | retrabalho de etapa inteira, ou gate aprovado indevidamente | uma reinvocação, percebida no mesmo turno |
  O segundo grupo já existe como instrução e já é invocado hoje — a investigação somente-leitura de
  `docs/gates/governanca.md`, a leitura destilada do `timing-log.md` na retrospectiva de fatia, a
  investigação de causa raiz antes de decidir o que pedir numa correção — e paga preço do primeiro.
- **O que mudou**
  **`docs/MODEL-TIERING.md`** (novo) — o teste das **cinco condições** para "trabalho bem definido"
  (formato de saída definido antes de invocar; resultado conferível sem refazer o trabalho; nenhum
  veredito/decisão; nenhuma ambiguidade esperada; somente leitura ou escrita mecânica), os **limites
  rígidos** e os candidatos típicos que já existem no pipeline. A dúvida sempre resolve para o modelo
  mais capaz, nunca para o mais barato.
  Limites rígidos, porque é onde a economia vira risco:
  - nenhuma etapa do pipeline desce de tier — incluindo as condicionais e os utilitários que escrevem
  artefato;
  - **nunca pelo frontmatter do agente**, que congelaria o tier para toda invocação daquele agente,
  inclusive as que decidem gate — a escolha é por invocação, de quem invoca;
  - nenhuma correção de achado de revisão, que toca código de produção via TDD (lá a economia é
  retomar o agente que já tem o contexto, não um modelo mais barato);
  - **uma única repromoção**: duas rodadas baratas mais uma cara saem mais caro que a cara sozinha.
  **`docs/gates/governanca.md`** — gate transversal, ao lado do bullet de sub-tarefa isolada que já
  estava lá: é onde a decisão aparece na prática, e todos os agentes leem esse arquivo.
  **O laço de avaliação** — coluna `Modelo` em `specs/_template/timing-log.template.md` (sub-tarefa
  repromovida gera **duas linhas**, não uma corrigida; o arquivo é append-only), lida pela
  retrospectiva de fatia (`/sdd-sre`, passo 5c) e pelo agente `sre`: econômico sem repromoção é
  candidato a virar padrão; o mesmo tipo repromovido duas vezes é sinal de que não passa no teste.
  Linha de **etapa** marcada `econômico` é limite violado, não economia — a coluna é o que torna isso
  auditável depois do fato. O resultado é promovido para `docs/PROJECT-CONVENTIONS.md` (projeto) ou
  para issue aqui (genérico), nunca fica no prompt da próxima invocação.
  **Aplicação concreta** nos dois pontos onde a delegação já existe: `/sdd-implement` passo 2a e
  `/sdd-sre` passo 5c.
  O doc nomeia tiers **por função** (`padrão da sessão`, `econômico`), não produtos: o conjunto de
  modelos disponíveis varia por conta/plano/harness, e um nome concreto caduca sem avisar. Projeto que
  queira fixar o mapeamento registra isso em `docs/PROJECT-CONVENTIONS.md`.
- **Sincronização**
  Replicado em `plugins/btt-sdd/` (doc novo + 5 docs/gates + 2 skills + 1 agente + o template do
  scaffold); `MODEL-TIERING` registrado na normalização de `scripts/check-plugin-sync.py`, que passa
  com **60 pares em dia**. Versão `1.37.26` → `1.38.0` (capacidade nova, não ajuste).
  Closes #383

(PR #384)

## 1.37.26 — 2026-10-09

- **Problema (issue #381)**
  O passo 5 de `agents/backend-developer.md`/`frontend-developer.md` e o gate de
  `docs/gates/implementacao.md` exigiam gravar o resultado da suíte completa em
  `specs/<slug>/coverage/<fatia>-<trilha>.md`. Mas uma **tarefa de investigação** — cuja definição no
  TRD é medir a plataforma contra spike descartável, antes de qualquer código de produção — não produz
  código em `src/` nem teste algum: não há cobertura nova a reportar. O agente ficava improvisando
  entre três saídas não documentadas (poluir o artefato de cobertura com "0 linhas novas", não
  registrar nada, ou escolher por conta própria escrever no artefato da tarefa).
  A classe é maior que o caso particular: investigação/spike, tarefa de ferramental e a exceção
  docs-only já descrita têm o mesmo perfil — nada a cobrir, mas a suíte precisa ser verificada — e só
  a terceira tinha tratamento escrito.
- **O que mudou**
  Uma exceção irmã da já existente para commit docs-only, nos três lugares:
  - `.claude/agents/backend-developer.md`, passo 5
  - `.claude/agents/frontend-developer.md`, passo 5
  - `docs/gates/implementacao.md`, bullet do artefato de cobertura
  A suíte completa continua **obrigatória** (provar que nada quebrou não depende de ter havido linha
  nova a cobrir), mas o registro vai para o **artefato da própria tarefa** — com o mesmo commit SHA e
  a mesma reconciliação nominal de falhas do passo 5a — e o arquivo de cobertura **não ganha rodada
  nova** nem é criado por causa dela.
  Os dois motivos ficam explícitos no texto, porque ambos são mecânicos:
  1. o campo `Commit` é o último commit que tocou código, e uma tarefa sem código de produção não o
  move — o artefato existente continua correto sozinho, e uma rodada de "0 linhas novas" induz
  revisor a reexecutar a suíte por um metadado parado;
  2. a tabela de histórico desse arquivo é disputada com a trilha que roda em paralelo — escrever ali
  uma rodada que não mede código novo é conflito mecânico de merge de graça, o mesmo que a coluna
  Status do TRD já causou.
  O registro não fica invisível: `qa-engineer` e `security-engineer` já varrem os artefatos de tarefa
  de investigação da spec.
- **Sincronização**
  Replicado em `plugins/btt-sdd/` (2 agentes + gate); `python scripts/check-plugin-sync.py` verde.
  Versão do plugin `1.37.25` → `1.37.26` (ajuste, não capacidade nova).
  Closes #381

(PR #382)

## 1.37.25 — 2026-10-09

- **Problema (issue #379)**
  O passo 6 de `skills/create-project/SKILL.md` mandava seguir o processo descrito em
  `agents/product-design.md`. Esse é o processo do **agente**, e dois gates obrigatórios de
  `docs/gates/prd.md` não vivem nele — vivem no **orquestrador** da etapa 1
  (`skills/prd/SKILL.md`, passo 2b):
  1. Oferecer ao usuário ver opções de wireframe/protótipo antes das histórias (aceite ou recusa,
  nunca silenciado), com a consulta sobre estabelecer `docs/DESIGN-SYSTEM.md` quando ele ainda
  não existe.
  2. Acionar o `ux-designer` em modo consultoria — `agents/ux-designer.md` só aceita essa invocação
  vinda de quem orquestra a etapa 1, nunca direto.
  O próprio `agents/product-design.md` (passos 3c/3d) confirma que esses insumos chegam de quem
  orquestra, e o agente não tem as ferramentas (`Artifact`, skill `design`, Agent tool) para
  produzi-los. Resultado: uma sessão que seguisse o passo 6 ao pé da letra pulava os dois gates, e o
  primeiro PRD do projeto nascia reprovado no gate da própria etapa — justamente a rodada de maior
  efeito composto, porque é nela que `docs/DESIGN-SYSTEM.md` nasce para todas as features seguintes.
- **O que mudou**
  - **Passo 6** agora manda conduzir o processo completo de `/sdd-prd` (`skills/prd/SKILL.md`,
  passos 2b a 5), explicando por que seguir só o agente não basta e quais são os dois gates que
  ficam fora dele. Registra também que, em `create-project`, o passo 2b praticamente sempre
  dispara — é um produto inteiro nascendo — salvo quando o usuário descreveu explicitamente algo
  sem interface.
  - **Frase de abertura da skill** ("segue o processo do `product-design` diretamente") corrigida
  pelo mesmo motivo.
  - Replicado nas duas cópias (`.claude/skills/` e `plugins/btt-sdd/skills/`);
  `python scripts/check-plugin-sync.py` verde.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.37.24` → `1.37.25` (patch — ajuste de
  instrução, sem capacidade nova).
  Efeito colateral bom: ao apontar para os passos 2b a 5, o primeiro PRD passa a registrar também o
  `timing-log.md` (passo 3c), que antes ficava de fora em projetos criados por `create-project`.
  Closes #379

(PR #380)

## 1.37.24 — 2026-10-08

  Closes #372
- **Problema**
  O gate de lições (`docs/gates/licoes.md`) define, para cada entrada de `docs/LESSONS-LEARNED.md`, um campo **`Escalonamento`** — a oferta feita ao usuário sobre endereçar a causa raiz da lição — e manda **ler** o campo antes de ofertar de novo, para não reabrir uma oferta já recusada.
  **O que ele não fazia é atribuir a alguém escrever a resposta de volta no campo.**
  Consequência medida: uma entrada tinha `Escalonamento: sem resposta` **e a resposta existia** — o usuário havia decidido, e a decisão estava registrada no corpo do artefato da rodada, não no campo. O `sre` da fatia seguinte completou o campo por iniciativa própria. Foi a **terceira vez na mesma spec** que uma decisão do usuário existia em prosa e não no campo estruturado que a consome.
  É assimetria de ciclo fechado: o pipeline instrui a **ler** e a **ofertar**, mas não a **responder**. Qualquer projeto com mais de uma fatia por spec acumula o mesmo descompasso, e o custo é uma oferta repetida ao usuário — exatamente o que o campo foi criado para evitar.
- **O que mudou**
  - **`docs/gates/licoes.md`**: dono nominal do preenchimento — o orquestrador da skill de revisão que obteve a decisão do usuário escreve a resposta no campo `Escalonamento` **no mesmo turno**, não só no artefato da rodada. Mais o item de que uma entrada com `sem resposta` cuja decisão consta em artefato de rodada anterior é **inconsistência a corrigir**, não oferta em aberto (quem lê o campo confere também o artefato da rodada em que a oferta foi feita).
  - **Passos de intermediação de pergunta das skills de revisão** (`code-review` 3c, `ux-review` 4c, `qa` 3c, `security` 3c, `sre` 4b): a instrução de escrever a resposta no campo da entrada correspondente, no ponto exato em que a decisão do usuário é obtida.
  Replicado em `plugins/btt-sdd/` (`check-plugin-sync.py` verde); versão do plugin 1.37.23 → 1.37.24.

(PR #378)

## 1.37.23 — 2026-10-08

  Closes #371
- **O padrão**
  Uma correção passou a renderizar uma região de anúncio (`role="status"`) **sempre montada**, com a classe `empty:hidden` para não deixar um `gap` órfão no layout. **Quatro artefatos** passaram a afirmar essa garantia — a seção 11 do TRD, o docblock do componente, o `code-review.md` e o `POST-MERGE-VALIDATION.md`. A suíte ficou verde. **Nenhuma das três etapas de revisão seguintes pegou nada por leitura.**
  A reverificação de UX pegou, e o mecanismo é o ponto: o `ux-designer` **compilou `empty:hidden` com o Tailwind daquele repositório e injetou a regra no jsdom** antes de consultar. Com a regra presente, `getByRole('status')` devolve **0** enquanto a região está vazia e 1 depois do texto — ou seja, ela **nunca está na árvore de acessibilidade antes de ter conteúdo**, que é exatamente o mecanismo que a correção existia para eliminar. Agravante medido: aquele desfecho tinha um **único** canal de anúncio. O `qa-engineer` confirmou do outro lado, no **CSS publicado**: `empty:hidden` com contagem **0** nos dois arquivos de CSS do build.
  O defeito tem um **irmão** na mesma fatia: o extrator do Tailwind varre o arquivo **inteiro, comentários incluídos**, então citar o nome literal da classe antiga no comentário que explicava a mudança mantinha a **regra morta dela no CSS de produção**. Mesma causa — a relação entre classe escrita no código e regra que existe no documento **não é lida, é compilada**.
  `docs/gates/ux.md` já exigia que o método da rodada estivesse documentado e que leitura estática nunca fosse apresentada como equivalente a verificação ao vivo — o que está certo e **não é suficiente**: aqui o método **era** execução instrumentada, e ainda assim mediu o **documento errado**, porque o jsdom é ignorante sobre o CSS do projeto. Qualquer projeto com CSS utilitário (Tailwind, UnoCSS, CSS Modules com composição) verificando UX em jsdom tem a mesma lacuna, e ela é **silenciosa por construção**: a asserção passa, e o que ela afirma é falso.
- **O que mudou**
  - **`agents/ux-designer.md`**: em DOM sem engine de estilo, veredito que depende de visibilidade, presença na árvore de acessibilidade, ordem de foco ou geometria exige a regra de CSS **compilada com a toolchain do projeto e injetada no documento** antes da consulta. Sem isso, a área é declarada explicitamente **não medida** — nunca "sem achados".
  - **`docs/gates/ux.md`**: item correspondente — "está montado" / "está na árvore de acessibilidade" é asseverado contra o documento **com CSS aplicado**, nunca contra a presença da classe no JSX.
  - **`agents/qa-engineer.md` (passo 2b-bis)** e **`docs/gates/qa.md`**: a contrapartida que fechou o caso — asseverar sobre o **CSS publicado** do build (presença quando a garantia depende dela existir, **ausência** quando depende de ela ter sido removida), porque o extrator varre o arquivo inteiro e o fonte **não decide** o que existe em produção.
  Replicado em `plugins/btt-sdd/` (`check-plugin-sync.py` verde); versão do plugin 1.37.22 → 1.37.23.

(PR #377)

## 1.37.22 — 2026-10-08

  Closes #370
- **O padrão**
  Numa fatia real, **seis** frases de artefato que descreviam o *mecanismo* pelo qual uma garantia era obtida foram desmentidas por medição em quatro rodadas de revisão distintas — sempre pela correção **seguinte**, nunca por erro no momento da escrita. As ocorrências não se distribuem ao acaso: **quatro das seis** estavam na seção 11 do TRD (plano de testes) ou em docblock de teste — a seção cujo conteúdo **é** mecanismo por definição, e mecanismo é exatamente o que cada rodada de correção troca.
  E corrigir uma frase dessa classe **não basta**. A linha do componente foi reescrita trocando contagem por critério ("nos 6 estados" → "toda renderização visível"). A reescrita estava certa — e o defeito seguinte entrou pelo **segundo eixo da mesma frase**: a enumeração de *quais propriedades* asseverar. Duas mutações sobreviveram à **suíte inteira** (1644/1644 verdes), com o card do iPhone dizendo "Fica na área de trabalho e na barra de tarefas" e a instrução do iOS exibida no Android. Uma terceira (o título) nem constava do relatório.
  O eixo gêmeo: a frase corrigida num lugar e não no irmão. O mecanismo estava descrito em **quatro** lugares (port no TRD, docstring do port, docblock do provider, docblock da cópia) mais a célula de critério de outra seção; a correção acertou três. Um `grep -rn` pela afirmação antiga acha o que nenhuma revisão de prosa acha.
  Contra-exemplo útil da mesma fatia: um ADR **atravessou a fatia inteira sem ser desmentido**, porque dizia **onde** o listener vivia, não **o que** o fazia existir. Afirmação mais fraca, e por isso durável.
- **O que mudou**
  - **`agents/architect.md`, passo 8**: **critério** em PRD/TRD/ADR, **mecanismo** no código e nos testes. Quando o mecanismo precisa ser registrado (contrato entre dois módulos), marcá-lo como mecanismo e guardá-lo **por teste**, não por prosa. Mais os dois eixos a evitar na redação (contagem; enumeração de propriedades) e o contra-exemplo durável.
  - **`docs/gates/trd.md`**: item novo barrando contagem e enumeração de propriedades na seção 11, com a evidência medida.
  - **`docs/gates/governanca.md`** e **`skills/amend/SKILL.md` (passo 3b)**: as duas perguntas obrigatórias ao corrigir uma frase de mecanismo — *"quantas enumerações esta frase tem?"* (trocar uma e deixar a outra **move** o defeito, e o movimento é invisível porque a frase agora *parece* corrigida) e *"em quantos lugares este mesmo mecanismo está descrito?"* (com `grep` pela afirmação antiga antes de fechar o achado, substituindo cada reaparição por referência ao lugar canônico).
  Replicado em `plugins/btt-sdd/` (`check-plugin-sync.py` verde); versão do plugin 1.37.21 → 1.37.22.

(PR #376)

## 1.37.21 — 2026-10-08

  Closes #369
- **Problema**
  Três defeitos de **medição** tornavam a série do `timing-log.md` não comparável entre fatias — todos de instrução, nenhum de disciplina:
  1. **Contador cumulativo de agente retomado registrado como se fosse por invocação.** Numa fatia real: 83m04s reportados que não cabiam no relógio de parede (o incremental era ~35m), e `subagent_tokens` monotônicos ao longo de 8 invocações (`288.900 → … → 761.011`) com os usos de ferramenta oscilando. 761k é o **total de vida** do agente; o custo marginal das 7 rodadas de correção foi 472.111 tokens (~67k/rodada). Lido como bruto, o log afirma que retomar agente é caro — quando a medida correta prova o contrário (instâncias frescas de revisor custaram 223k–266k só para se orientar).
  2. **Etapa com trabalho real de orquestrador e nenhuma linha.** O SRE de uma fatia tinha só a linha do agente (47m32s), enquanto a rodada roteava 6 pendências ao orquestrador, entregava um texto de issue para ele criar e conduzia a retrospectiva. A fatia anterior tinha a linha equivalente (~15m): a série comparou "SRE F-1 = 29m27s + 15m" com "SRE F-2 = 47m32s + 0".
  3. **Linha agregando duas etapas** ("Segurança + code review"), deixando a segurança com zero minuto de orquestrador atribuível apesar de 2 perguntas de decisão intermediadas e de uma convenção gravada em `docs/PROJECT-CONVENTIONS.md`.
  Os três empurram na **mesma direção**: superestimam as etapas de agente e subestimam as do orquestrador — exatamente o viés que a seção "Trabalho conduzido pelo orquestrador" foi escrita para corrigir. Com 29% do esforço medido de uma fatia sendo orquestrador (~177 min contra ~439 de agente), não é marginal.
- **O que mudou**
  - **`specs/_template/timing-log.template.md`**: a **assinatura de detecção** de contador cumulativo (o campo cresce monotonicamente entre rodadas sucessivas do mesmo agente enquanto o trabalho de cada rodada oscila) e a instrução de registrar a **diferença** contra a notificação anterior, com exemplo de linha. Mais a seção nova **"Uma linha por etapa, sempre"**: `0m` com justificativa em vez de nenhuma linha, e nenhuma linha nomeando duas etapas — paralelas são duas linhas com o mesmo horário de início, como o passo 4d já manda para trilhas full-stack.
  - **`skills/implement/SKILL.md`** (passos 3b e 5a) e os passos equivalentes de **`code-review`**, **`ux-review`**, **`qa`**, **`security`** e **`sre`**: as duas regras no ponto exato em que a linha é escrita.
  - **`docs/gates/{code-review,ux,qa,seguranca,sre}.md`**: item de encerramento exigindo que a linha desta rodada exista e nomeie **uma** etapa.
  - **`agents/sre.md`**: ao ler o log na retrospectiva, desconfiar de valor cumulativo em série antiga (gravada antes desta instrução) e analisar a diferença entre rodadas consecutivas — etapa sem linha nenhuma é etapa **não medida**, não etapa barata.
  Replicado em `plugins/btt-sdd/` (`check-plugin-sync.py` verde); versão do plugin 1.37.20 → 1.37.21.

(PR #375)

## 1.37.20 — 2026-10-08

  Closes #368
- **Problema**
  `skills/code-review/SKILL.md`, passo 5, encerrava a etapa dizendo que a próxima era sempre `/sdd-qa` — **a string `ux` não aparecia em nenhum lugar do arquivo**. A etapa 4b tem gate próprio (`docs/gates/ux.md`), critério objetivo e skill própria, mas nada no caminho que o orquestrador percorre a mencionava. Um gate condicional cujo roteamento não está escrito é um gate que depende de memória.
  Consequência medida: numa fatia real com superfície de UI (a marca do app virou link, +31/-4 num componente de topbar) a **4b foi pulada inteira** e a fatia foi mergeada em `main` sem revisão de usabilidade — numa spec onde a etapa já existia havia semanas. Quando a 4b finalmente rodou na fatia seguinte, achou um defeito da classe que **só** ela encontra (o desfecho de `requestInstall()` descartado, deixando o card byte a byte idêntico depois de uma instalação bem-sucedida).
- **O que mudou**
  - **`skills/code-review/SKILL.md`, passo 5**: bifurcação explícita aplicando o critério de `docs/gates/ux.md` sobre o diff revisado — com superfície de UI perceptível, a próxima é `/sdd-ux-review`; sem, é `/sdd-qa` e a decisão de pular fica registrada sob o heading padronizado `## Decisão: UX review pulado (justificado)`.
  - **Mesma skill, cabeçalho**: a frase "esta skill em si não carrega lógica extra além de acionar o agente" deixou de ser verdade (agora carrega o roteamento) — e era justamente o convite a pulá-la.
  - **`docs/gates/code-review.md`**: item novo exigindo que a rodada **declare no artefato** se a fatia tem ou não superfície de UI. A informação é de quem leu o diff, e declará-la deixa a decisão auditável em vez de implícita.
  Replicado em `plugins/btt-sdd/` (`check-plugin-sync.py` verde); versão do plugin 1.37.19 → 1.37.20.

(PR #374)

## 1.37.19 — 2026-10-08

  Closes #367
- **Problema**
  `docs/gates/qa.md`, `docs/gates/ux.md` e `docs/gates/seguranca.md` exigiam `code-review.md` com veredito aprovado como pré-condição, mas **nenhum exigia que essa aprovação cobrisse o HEAD atual da branch**. A única checagem de frescor que as skills faziam era contra `main` (`git rev-list --count HEAD..origin/main`) — que não vê a própria branch da fatia avançar depois do carimbo.
  Não é um desvio raro: a **etapa 4b roda depois da 4 e gera código de produção**, então o caso normal (4b aprova com ressalvas de comportamento → correções tocam produção → QA) atravessa duas etapas com um carimbo que já não corresponde ao código. Na fatia real que originou a issue foram 5 arquivos de produção e 824 inserções depois do sha aprovado, com dois commits de correção de UX nunca revisados; a rodada escopada ao delta **reprovou** (um bloqueante de foco roubado a cada volta à tela, e um 5º sinal de plataforma sem menção em `specs/`/`docs/`/código). Foi pego só porque o `qa-engineer` inventou a checagem por iniciativa própria.
- **O que mudou**
  - **`docs/gates/{qa,ux,seguranca}.md`**: item novo exigindo que `git diff --name-only <sha da rodada que aprovou>..HEAD -- <diretórios de produção>` seja vazio. Se não for, a etapa não começa — roda-se uma rodada de code review escopada ao delta, numa instância nova.
  - **`skills/qa/SKILL.md`** e **`skills/ux-review/SKILL.md`**: passo `2a` operacionalizando a checagem, explicitamente distinto do `2b` (que checa `main`).
  - **`skills/ux-review/SKILL.md`**: passo `6b` tornando explícito que correção de achado de UX que toca produção volta para `/sdd-code-review` **escopado ao delta**, não direto para `/sdd-qa`.
  Replicado em `plugins/btt-sdd/` (`check-plugin-sync.py` verde); versão do plugin 1.37.18 → 1.37.19.

(PR #373)

## 1.37.18 — 2026-10-05

- **Problema**
  O GitHub limita nome de label a **50 caracteres**, e a convenção `spec:<projeto>/<slug>` estoura isso rotineiramente. Reproduzido de verdade na rodada anterior de `/repo-issues`, ao rotular a #351:
  ```
  $ gh label create "spec:projeto-A/0006-navegacao-global-menu-topbar-alertas" ...
  HTTP 422: Validation Failed
  name is too long (maximum is 50 characters)
  ```
  Nenhuma das duas instruções que montam esse nome mencionava o limite — `.claude/skills/sdd-sre/SKILL.md` passo 5c (onde os labels nascem, na retrospectiva de fatia) e `.claude/skills/repo-issues/SKILL.md` passo `d2` (que reusa a convenção). Então o agente monta o nome, recebe o 422, e **em seguida o `gh issue create --label` também falha** com `'<label>' not found` — dois erros em sequência cuja causa real está na primeira chamada.
  Não é um slug azarado: `spec:` + o nome do repositório já consome ~20 caracteres (`spec:projeto-A/` = 19) e slug de spec com 32+ é rotineiro. Como a retrospectiva é obrigatória ao final de **toda** fatia aprovada, a falha é recorrente por construção — e a issue acaba sem o label de origem que existe justamente para permitir filtrar depois todas as issues de uma mesma spec.
- **Mudança**
  Duas regras, não uma:
  1. **Truncar** o `<slug>` no último limite de palavra (`-`) que couber, **preservando o prefixo numérico da spec** (é ele que identifica), com o slug completo na `--description`, que não tem esse limite:
  `spec:projeto-A/0006-navegacao-global-menu-topbar-alertas` (60) → `spec:projeto-A/0006-navegacao-global-menu` (45).
  2. **Procurar o label existente por prefixo** (`spec:<projeto>/<NNNN>`), não por nome exato, e **reusar** o que já houver.
  A segunda regra vai além do que a issue pedia, e é o que torna a primeira utilizável: o nome truncado é a **chave de filtro** da spec. Duas fatias da mesma spec cortando em pontos diferentes criariam dois labels para a mesma origem, quebrando exatamente o filtro que o label existe para dar. Truncar sem fixar a estabilidade do nome trocaria um erro visível (422) por um silencioso.
- **Escopo**
  - `.claude/skills/sdd-sre/SKILL.md` + a cópia `plugins/btt-sdd/skills/sre/SKILL.md`
  - `.claude/skills/repo-issues/SKILL.md` — **sem** réplica no plugin, por ser manutenção exclusiva deste repositório (`plugins/btt-sdd/README.md`, exceção deliberada)
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.17` → `1.37.18`
  Closes #365

(PR #366)

## 1.37.17 — 2026-10-05

- **Problema**
  Perguntas de tarefa de investigação (`premissa-nao-validada`) eram catalogadas pela **área da feature** a que pertencem superficialmente — instalabilidade, upload, notificação. Mas o que importa é **qual decisão elas alimentam**, e essa decisão pode estar em outra fatia, outra etapa ou outro domínio. Quando divergem, **o agente que precisa da resposta nunca vê a pergunta**: ele procura premissas do próprio domínio, não a lista de perguntas da área onde ela nasceu.
  Já aconteceu de verdade (achado `SEC-F1-4`, fatia F-1 de `0047-app-instalavel-pwa`): a pergunta 5 da T-1 estava catalogada como pergunta de **instalabilidade** — "a sessão Sanctum cross-subdomain sobrevive a fechar e reabrir no standalone?". Ela decidia uma propriedade de **segurança de outra fatia**: se o standalone do iOS tiver partição de armazenamento própria, o `clearAll()` do logout da F-3 alcança apenas o contexto que executou o logout, e o requisito que existe para "outra pessoa no mesmo aparelho" passa a valer **por contexto, não por aparelho**.
  Funcionou porque o `security-engineer` leu o artefato de investigação inteiro por iniciativa própria, numa fatia em que não era obrigado a isso. O `security-engineer` da F-3 iria procurar premissas de segurança, não a lista de perguntas de instalabilidade da F-1.
- **Mudança**
  Duas pontas — quem escreve a pergunta e quem precisa encontrá-la:
  - **`agents/architect.md`, passo 1c**: nova obrigação do formato do artefato de investigação — cada pergunta declara a **tarefa**, a **fatia** e, quando a consequência é de outro domínio, a **etapa de revisão** que vai precisar da resposta (ex.: "alimenta o controle de limpeza de armazenamento da T-15, F-3; consequência de **segurança**").
  - **`agents/security-engineer.md` e `agents/qa-engineer.md`, passo 1**: varredura dos artefatos de investigação da spec — desta fatia **e das anteriores** — por perguntas que alimentam a própria etapa, inclusive catalogadas sob outra área. Para o QA o enquadramento é o que a issue não explicitava mas segue do mesmo mecanismo: uma resposta que restringe o alcance de um comportamento reescreve o critério de aceite em validação, e um critério validado contra a leitura errada passa verde sem cobrir o requisito.
- **Escopo**
  - `agents/architect.md`, `agents/security-engineer.md`, `agents/qa-engineer.md` + as 3 cópias do plugin
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.16` → `1.37.17`
  Closes #357

(PR #364)

## 1.37.16 — 2026-10-05

- **Problema**
  O item "`main` protegida" da seção CD de `specs/_template/sre-review.template.md` agregava seis sub-condições numa linha só (push direto bloqueado, PR obrigatório, status checks, `strict`, sem force-push/deleção, `enforce_admins`). Um item agregado marcado ✅ **esconde** a sub-condição que falha, porque **quem lê o checklist não lê o parágrafo de evidência ao lado**.
  Não é teórico: `enforce_admins: false` foi reportado como *estado*, dentro da evidência de um item marcado ✅, em **7 ocorrências ao longo de 6 specs** do mesmo projeto, e nunca virou ressalva. Só caiu nesta rodada, quando virou o achado `SRE-F1-6`. A sub-condição que faltava era **a única camada do pipeline que não depende de um agente obedecer** — todo o resto é disciplina; essa era mecanismo.
- **Mudança**
  Três camadas, da mais geral para a mais estrutural:
  1. **`docs/gates/governanca.md`** — o princípio geral, lido por todos os agentes de revisão: nenhum veredito agregado fica verde com uma sub-condição falhando. Vale para item de checklist **e** para o veredito de uma "área de revisão" que agrega vários achados.
  2. **`agents/sre.md`, passo 4** — a instrução no ponto exato em que o checklist é preenchido.
  3. **`specs/_template/sre-review.template.md`** — o item de proteção de `main` decomposto em uma linha por sub-condição, para que a **estrutura** force o comportamento em vez de depender da instrução.
- **Uma divergência da issue, deliberada**
  A issue sugeria acrescentar a instrução também a `agents/code-reviewer.md`, `qa-engineer.md` e `security-engineer.md` "pela mesma simetria". Verifiquei: **nenhum** desses três templates usa checklist de caixas (`grep -c '^- \[ \]'` → 0 em `code-review`, `qa-report`, `security-review` e `ux-review`; 17 só em `sre-review`). Uma instrução sobre "marcar ✅ um item de checklist" nesses agentes seria letra morta. O princípio geral em `governanca.md` já os cobre pela via que eles de fato usam — o veredito por área de revisão, que também é agregado.
- **Escopo**
  - `docs/gates/governanca.md`, `agents/sre.md`, `specs/_template/sre-review.template.md` + as 3 cópias do plugin (com as referências de doc adaptadas no scaffold)
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.15` → `1.37.16`
  Closes #356

(PR #363)

## 1.37.15 — 2026-10-05

- **Problema**
  Quando uma etapa de revisão entrega um fato **medido**, o orquestrador naturalmente o inclui na instrução da etapa seguinte — e deve, para que ela não refaça o trabalho (é o que as seções "o que a próxima etapa herda" existem para fazer). Mas a repetição **lava a origem**: o que era "medido pela etapa X, com o método Y" chega à etapa seguinte como premissa sem procedência, indistinguível de um fato do desenho, e quem recebe não tem como saber que precisa reconferir.
  Aconteceu duas vezes na mesma fatia (F-1 de `0047-app-instalavel-pwa`):
  1. O achado `SEC-F1-3` afirmava que o pulo de um job de CI vinha "**inteiramente**" de `is_draft=true`, porque "neste PR `code=true`". Repassado ao `sre` como fato medido, o `sre` reconferiu por iniciativa própria: o `code=true` vinha de ler `base` como `pull_request.base.sha`, mas em evento `synchronize` o `base` efetivo é `github.event.before`. Nos logs reais, um run deu `code=false` e outro `code=true` **na mesma branch** — a causa varia de run para run, e **o defeito era pior do que o descrito**, não menor.
  2. O orquestrador afirmou "1 módulo do Workbox importado" — verdade no fonte, errado sobre o artefato construído (que tinha marcadores de 4) — e o `security-engineer` corrigiu.
  Nos dois casos o resultado foi bom **por iniciativa do agente que recebeu**, não por instrução.
- **Mudança**
  Passo `3a.` novo nas quatro skills de revisão (`sdd-code-review`, `sdd-qa`, `sdd-security`, `sdd-sre`), logo após o passo que monta a instrução do agente: diga **quem mediu e como**, e marque se o fato é carga para alguma conclusão desta etapa. Inclui explicitamente a medição **do próprio orquestrador** — o caso (2) acima, que a formulação original da issue não cobria.
- **Escopo**
  - 4 skills + as 4 cópias em `plugins/btt-sdd/skills/`
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.14` → `1.37.15`
  Closes #355

(PR #362)

## 1.37.14 — 2026-10-05

- **Problema**
  O `architect` mandava posicionar toda tarefa de investigação `premissa-nao-validada` como a **primeira** tarefa da primeira fatia que depende dela, sem distinguir duas classes que se comportam de forma oposta:
  - **Mede a plataforma isoladamente** ("que código HTTP o serviço devolve para endereço revogado") → pode e deve vir antes do código, `Depende de` = `nenhuma`.
  - **Mede o comportamento da plataforma contra artefato produzido por outras tarefas da mesma fatia** ("o navegador oferece instalar com *este* manifest e *este* service worker?") → **não pode** preceder o artefato. Marcá-la como primeira cria uma dependência circular não declarada.
  Já aconteceu de verdade (fatia F-1 de `0047-app-instalavel-pwa`): a tarefa T-1 era uma investigação com `Depende de` = **`nenhuma`**, e a seção do plano de testes declarava que as investigações rodavam "antes de escrever código". **Todas as cinco perguntas** exigiam o manifest, os ícones e o service worker de três tarefas irmãs (T-2, T-3, T-4). A fatia foi reordenada em execução, por decisão do usuário, com emenda ao TRD registrando a impossibilidade — e o mesmo TRD tinha outras duas investigações com o mesmo defeito (T-7/F-2 e T-11/F-3), prontas para repetir o episódio duas vezes.
- **Mudança**
  - `agents/architect.md`, passo da decomposição: a distinção entre as duas classes, com as três obrigações do segundo caso (`Depende de` nunca `nenhuma`; o texto da tarefa diz que ela roda **ao fim** da fatia; o plano de testes qualifica **quais** investigações rodam antes do código) e o teste de um passo que separa os casos — *a medição é possível com o repositório como está hoje?*
  - `specs/_template/trd.template.md`, seção 13: a convenção correspondente, logo depois do parágrafo "Tarefa de investigação vem primeiro" que ela qualifica.
- **Escopo**
  - `agents/architect.md` + cópia do plugin; `specs/_template/trd.template.md` + cópia do scaffold
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.13` → `1.37.14`
  Closes #354

(PR #361)

## 1.37.13 — 2026-10-05

- **Problema**
  A seção "O que a coluna 'Duração' mede" de `specs/_template/timing-log.template.md` não dizia nada sobre **agente retomado via `SendMessage`**, e nesse caso o `duration_ms` da notificação de conclusão pode ser cumulativo desde a criação do agente. Pior: o comportamento é **inconsistente**, tanto entre campos quanto entre invocações.
  Caso real (fatia F-1 de `0047-app-instalavel-pwa`, mesmo `frontend-developer` retomado 3×):
  | Rodada | `duration_ms` | `tool_uses` | `subagent_tokens` |
  |---|---|---|---|
  | 1 | 2.877.625 (47m58s) | 176 | 307.764 |
  | 2 | 4.983.860 (83m04s) | 245 | 355.211 |
  | 3 | 709.778 (11m50s) | 56 | 403.335 |
  A rodada 2 não cabe no wall-clock disponível depois da rodada 1, e `tool_uses`/`subagent_tokens` crescem — o que sugere cumulativo. Mas a rodada 3 quebra o padrão, e numa outra spec as três rodadas do mesmo agente tiveram durações **decrescentes**, incompatíveis com cumulativo.
  Isso importa porque a retrospectiva de fatia (`/sdd-sre`, passo 5c) lê esse arquivo como evidência concreta de performance e trata etapa desproporcionalmente lenta como candidata a issue. Uma linha de 83m que na verdade foram ~35m faz a análise concluir o oposto do que os dados mostram. Na fatia onde isso apareceu, o orquestrador registrou a ambiguidade na própria linha — **por zelo, não por instrução**.
- **Mudança**
  Parágrafo novo na seção, mandando conferir o número contra o relógio de parede antes de registrá-lo, com exemplo de linha ressalvada, e apontando para a instrução que resolve o caso na origem (#352 — anotar o horário antes do `SendMessage`).
- **Escopo**
  - `specs/_template/timing-log.template.md` + a cópia em `plugins/btt-sdd/skills/create-project/scaffold/specs/_template/`, com as referências de skill adaptadas ao namespace do plugin (`/btt-sdd:implement`, `/btt-sdd:sre`), como a linha 73 já fazia
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.12` → `1.37.13`
  Closes #353

(PR #360)

## 1.37.12 — 2026-10-05

- **Problema**
  As skills de etapa mandam anotar o horário **no passo que invoca o agente via Agent tool** (`sdd-implement` passos 3/4d, `sdd-code-review`/`sdd-qa`/`sdd-security`/`sdd-sre` passo 3), e o passo 3b manda registrar a duração no `timing-log.md`.
  Mas as **rodadas de correção não passam por ali** — elas retomam o agente via `SendMessage` ("Retomando para corrigir achados de revisão"). O passo 3b daquela seção manda *registrar* a duração, mas nenhum passo manda **anotar o horário antes** do `SendMessage`. Quem segue a instrução ao pé da letra descobre, ao terminar, que não tem o horário de início.
  Resultado real: três linhas de um mesmo `timing-log.md` registradas como "horário de início aproximado — não anotado antes do `SendMessage`", uma delas com o número derivado incompatível com o relógio de parede. O mesmo já havia ocorrido três vezes numa segunda spec.
  O custo não é cosmético: a retrospectiva de fatia (`sdd-sre`, passo 5c) lê esse arquivo como evidência concreta de performance e trata etapa desproporcionalmente lenta como candidata a issue.
- **Mudança**
  - `sdd-implement`, passo 1 da seção "Retomando": acrescenta a mesma frase que já existe nos passos de invocação, com o motivo (o `duration_ms` de agente retomado pode ser cumulativo desde a criação do agente — ver #353, correlata).
  - `sdd-code-review`, `sdd-qa`, `sdd-security`, `sdd-sre`, passo 3b: nota de que a reverificação pontual que retoma o agente via `SendMessage` também não passa pelo passo 3, e precisa da mesma anotação.
- **Escopo**
  - 5 skills + as 5 cópias em `plugins/btt-sdd/skills/`
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.11` → `1.37.12`
  Closes #352

(PR #359)

## 1.37.11 — 2026-10-05

- **Problema**
  O passo de preparação dos cinco agentes de revisão (`code-reviewer`, `qa-engineer`, `security-engineer`, `sre`, `ux-designer`) prescrevia:
  > **Antes de ler qualquer artefato ou rodar qualquer suíte, confirme que está na branch do PR sendo revisado** (`git fetch origin <branch> && git checkout <branch>`) — (...) Se estiver rodando em working tree isolado, o checkout acontece no próprio worktree, não no working directory principal.
  A segunda frase dá a entender que o comando funciona em worktree isolada. **Não funciona** — e worktree isolada é justamente o modo obrigatório dessas invocações (`isolation: "worktree"`, "é o padrão desta invocação" nas skills de revisão). O orquestrador que abriu o PR normalmente tem a branch como `HEAD` no worktree principal, e o Git recusa a mesma branch em dois worktrees:
  ```
  fatal: 'fix/topbar-alvo-de-toque-44px' is already used by worktree at 'C:/repositorios/projeto-A'
  ```
- **Mudança**
  O passo agora diz que o checkout **vai** falhar nesse modo e manda ir direto para a variante que funciona — branch temporária rastreando `origin/<branch>` (ou `--detach`), com `git push origin HEAD:<branch>` ao final. É a mesma prescrição que `docs/GIT-WORKFLOW.md` já documentava na seção "Isolamento de working tree entre agentes concorrentes", mas que nenhum agente lia no próprio passo de preparação — por isso cada rodada re-derivava o contorno do zero.
  Inclui também o efeito colateral que não estava documentado em lugar nenhum: **depois do push, a branch local do checkout principal fica atrás do remoto**, e o relatório da rodada precisa avisar isso para quem orquestra fazer `git pull` antes de seguir.
  Alinhei com a prescrição já existente (branch temporária) em vez do `--detach` literal da issue, para não criar duas prescrições divergentes para o mesmo problema; o `--detach` fica como alternativa no próprio bloco de comandos.
- **Escopo**
  - 5 agentes de revisão + as 5 cópias em `plugins/btt-sdd/agents/`
  - `python scripts/check-plugin-sync.py`: verde
  - versão do plugin: `1.37.10` → `1.37.11`
  Closes #351

(PR #358)

## 1.37.10 — 2026-10-01

- **O que mudou**
  Aplica o **bullet 2** da #343 na variante escolhida: **limitar a leitura, sem mover rodada nenhuma**.
  O arquivo continua inteiro e append-only — o que muda é quanto dele quem lê precisa ler. Nenhum
  `<artefato>-historico.md`, e portanto nenhum risco para os scripts de `/sdd-status`/`/sdd-pending`,
  que continuam vendo a tabela de histórico e as flags de revalidação no mesmo arquivo de sempre.
  - **`docs/AGENT-PREAMBLE.md`** (as duas cópias) — seção nova, "Artefato in-place que acumulou rodadas":
  leia por completo a tabela "Histórico de aprovações por fatia" (é o índice, e é curta) e a **rodada
  vigente**; leia também a **penúltima** (é a que diz se um achado é reincidência e se uma ressalva
  anterior foi resolvida); rodadas anteriores são **referência sob demanda**, não leitura obrigatória.
  Com três exceções nomeadas em que o próprio passo exige alcançar mais atrás:
  - auditoria completa da fatia final (`security-engineer`/`sre`): diff acumulado desde a última
  rodada com `Profundidade = completo`, que pode estar várias fatias atrás;
  - promoção de lição aprendida (confirmar a 2ª ocorrência de um padrão);
  - qualquer flag `requer revalidação` em aberto.
  E o **lado de quem escreve**, que é o que torna a leitura limitada possível: identificar a rodada no
  cabeçalho da seção acrescentada, com o mesmo identificador da tabela (`F-N` ou `hotfix-<data>`). Mais
  o limite explícito: **nunca** reescrever rodada anterior para "enxugar" o arquivo — limitar leitura é
  escolha de quem lê, não apagamento de histórico (`docs/gates/governanca.md`).
  - **Os cinco templates de revisão** (as duas cópias de cada) — a frase que já dizia "editado in-place a
  cada fatia" agora diz também o que ler e como identificar a rodada acrescentada.
  O preâmbulo é lido por **todos** os agentes, então a regra chega aos cinco revisores **e** a quem
  implementa correção de achado (que lê o mesmo arquivo gigante para pegar os achados), sem cinco cópias
  do mesmo texto.
- **Por quê**
  Da própria issue: cada revisor lia in-place um `code-review.md` de **3.216 linhas**, com nove seções de
  rodadas históricas, só para encontrar a vigente.
- **Correção lateral no gate de sincronia**
  `scripts/check-plugin-sync.py` não tinha `AGENT-PREAMBLE` nem `SKILL-PREAMBLE` na lista de docs do
  pipeline, então a adaptação legítima do scaffold — `` `AGENT-PREAMBLE.md` do pipeline ``, exatamente a
  forma que o scaffold já usa para `TESTING.md` e `gates/*.md` — era reprovada como deriva nova. A regra
  genérica do sufixo "do pipeline" já existia; faltavam só os dois nomes na lista. Preferi isso a
  padronizar o texto para `docs/AGENT-PREAMBLE.md` nas duas cópias, porque dentro de um projeto gerado
  pelo scaffold esse caminho não existe — é justamente o que a convenção "do pipeline" distingue.
- **Verificação**
  `python scripts/check-plugin-sync.py` verde (59 pares). Confirmado também que nenhum agente/skill
  instrui o contrário: as ocorrências de "leia ... inteiro" em `code-reviewer.md`/`ux-designer.md` são
  sobre ler **arquivos de código** inteiros, não artefatos de revisão, e `/sdd-status`/`/sdd-pending` já
  preferem o script auxiliar a ler artefato inteiro. Parágrafos reempacotados na largura de linha do
  repositório (≤100 colunas).
  Plugin `1.37.10` (patch).
  Closes #343

(PR #350)

## 1.37.9 — 2026-10-01

- **Escopo: aplica o **bullet 1** da #343, e a issue **continua aberta****
  A #343 propõe duas coisas. Este PR aplica a primeira; a segunda (migrar rodadas anteriores à
  penúltima para `<artefato>-historico.md`) **não** entra aqui — ela muda o modelo de artefato (todo
  template de revisão + os 5 agentes de revisão), e os scripts de `/sdd-status`/`/sdd-pending` leem
  exatamente a tabela "Histórico de aprovações por fatia" e varrem o arquivo inteiro por flags de
  `requer revalidação`, então tirar rodadas de lá pode mudar veredito e a coluna Revalidar. Decisão do
  usuário, registrada em comentário na issue. Por isso o corpo diz `Refs #343`, não `Closes`.
- **O que mudou**
  - **`specs/_template/coverage-summary.template.md`** (as duas cópias) — o cabeçalho é da **rodada
  vigente, nunca histórico**: toda rodada que regrava o arquivo atualiza `Branch`, `Commit` e `Gerado
  em` com os valores da própria rodada. Mais: **a base de qualquer diff é calculada** (`git merge-base
  HEAD main`), nunca lida da coluna `Commit` de uma tabela de histórico.
  - **`sdd-hotfix/SKILL.md`, passo 4** (as duas cópias) — a mesma regra aplicada à rodada de hotfix,
  que é exatamente onde várias rodadas de correção convivem no mesmo PR.
- **Por quê**
  Depois de **três** rodadas de correção, o cabeçalho do resumo de cobertura ainda apontava para o
  commit da **rodada 1** — e é desse campo que o protocolo de reaproveitamento de evidência de
  `docs/TESTING.md` parte. Um SHA velho ali faz a etapa seguinte reaproveitar como fresca uma execução
  que não cobre o código atual. Pego por uma rodada de code review, não por quem escreveu o arquivo.
  No mesmo PR, o `security-engineer` teve de **apurar a base do diff sozinho** — registrou "base do diff
  apurada como `e07b976` após `merge-base` refutar `e6ff959`" — porque os cabeçalhos "vigente" dos
  artefatos nomeavam o commit de uma fatia anterior que tinha sido *squash-merged* e portanto não era
  mais ancestral. Se tivesse confiado na tabela, teria revisado o diff errado. A regra existia em
  detalhe, mas só em `agents/sre.md`; agora está onde o campo vive.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde. Plugin `1.37.9` (patch).
  Refs #343

(PR #349)

## 1.37.8 — 2026-10-01

- **O que mudou**
  `sdd-hotfix/SKILL.md` (as duas cópias):
  - **Passo 3b (novo)** — registro obrigatório em `specs/<slug>/timing-log.md`, com uma linha para
  **cada**: rodada de implementação (uma por invocação, não uma pelo hotfix inteiro — três rodadas de
  correção são três linhas), validação ao vivo do passo 4b (**inclusive as que reprovaram**), e
  diagnóstico de causa raiz conduzido pelo próprio orquestrador.
  - **Passo 4b** — uma linha dizendo que cada execução da validação ao vivo rende a própria entrada.
  - **Passo 6** — antes de seguir para 6b, confirmar que cada skill de revisão de fato registrou a
  própria invocação, e acrescentar a que faltar.
- **Por quê**
  A causa era **estrutural**, não esquecimento: a instrução de registro vive em `sdd-implement` (passos
  3b e 5a) e nas skills de revisão, mas `sdd-hotfix` **nunca mencionava** o `timing-log` — e invoca
  `backend-developer`/`frontend-developer` **direto** no passo 3, contornando `/sdd-implement` e, com
  ele, a instrução.
  Resultado medido: um hotfix com **seis** rodadas de trabalho — cinco de implementação, três validações
  ao vivo contra produção, um diagnóstico de causa raiz do orquestrador e uma rodada de SRE — deixou
  exatamente **duas** linhas no `timing-log.md` (code review 48m49s e segurança 22m47s). Quem lesse a
  série concluiria que o hotfix custou ~71 minutos. As rodadas de hotfix anteriores tinham sido
  registradas por zelo do orquestrador, não por instrução — o que torna a série de hotfix
  sistematicamente incompleta, e é justamente ela que a retrospectiva de fatia lê para achar etapa
  anormalmente lenta.
- **Achado lateral da issue, também resolvido**
  A issue nota que o `timing-log.md` **daquele projeto** afirmava que o template "não tem lugar para
  tempo de orquestrador", quando o template da instalação **tem uma seção inteira** sobre isso. O passo
  3b agora diz isso explicitamente: `orquestrador (sem agente)` é valor legítimo da coluna Agente, e uma
  cópia congelada do projeto que diga o contrário está desatualizada em relação ao template
  (`docs/SKILL-PREAMBLE.md`) — podendo ser corrigida na mesma rodada.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde. Plugin `1.37.8` (patch).
  Closes #342

(PR #348)

## 1.37.7 — 2026-10-01

- **O que mudou**
  `docs/gates/merge.md`: "CI verde" sai de dentro da lista de aprovações — onde era uma menção sem
  qualificação e sem dono — e passa a ser uma caixa própria, com **dono nomeado** (o orquestrador que
  conduz o merge) e as **duas partes** que a lição já prescrevia:
  1. **A suíte de fato executou.** `conclusion: success` no nível do run é ambíguo num projeto com
  cadência condicional de CI: pode significar "passou" ou "foi deliberadamente pulada". Inspecionar
  `steps[].conclusion` e confirmar que os passos caros rodaram em vez de aparecerem `skipped`.
  2. **O run verde cobre o código que vai ser mergeado.** Comparar o `headSha` do run com o
  `headRefOid` atual do PR e, quando diferirem, provar por diff que nada relevante ao workflow mudou.
  A caixa também diz explicitamente o que **não** é tarefa das etapas de revisão: um agente de revisão
  reporta o estado dos checks no artefato e encerra.
- **Por quê**
  Três etapas de revisão em sequência delegaram a verificação adiante: o **code review** fechou com o
  run `IN_PROGRESS` dizendo que aguardar o check era do orquestrador, a **segurança** fez o mesmo, e o
  **SRE** então encontrou o *required check* **VERMELHO** no HEAD (`Failed: 1, Passed: 266`) — e também
  delegou. Ninguém verificou. O orquestrador reportou ao usuário "601 testes verdes", que era verdade
  **na máquina local** e falso no runner.
  Agravante: antes disso, **6 runs em draft reportaram verde em 17–27 segundos** com os 15 passos caros
  `skipped`, por causa da cadência condicional de CI daquele projeto. Verde que não significava nada.
  A regra de quem espera o CI já existia em `docs/GIT-WORKFLOW.md` ("a espera é do orquestrador, não
  dos agentes de revisão"), e a verificação em duas partes já vivia na lição — mas **não no gate**, e o
  gate é o que a cadeia de revisão lê.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde. Plugin `1.37.7` (patch).
  Closes #341

(PR #347)

## 1.37.6 — 2026-10-01

- **O que mudou**
  - **`docs/TESTING.md`** — seção nova: todo valor observado numa medição ao vivo entra em artefato de
  spec, teste, dublê/mock, comentário ou XML doc **já substituído** por equivalente não atribuível a
  pessoa real, com a substituição feita no momento em que o valor sai da medição. Lista os quatro
  destinos pelos quais o dado real entra, em ordem de frequência observada — começando pelo menos
  visível, a **instrução passada a um agente**, que não é arquivo nenhum.
  - **`sdd-hotfix/SKILL.md`, passo 4a (novo)** — a mesma regra aplicada à rodada de hotfix, com ênfase
  explícita no corpo da instrução passada ao `backend-developer`/`frontend-developer`.
  - **`docs/gates/seguranca.md`** — caixa nova, para a regra bloquear e não só existir. Inclui "não
  presuma que um identificador bem formado num teste é placeholder sintético — confira o dígito
  verificador".
  **Substituir não é perder evidência**: o que explica o defeito é a assinatura do incidente (contagem
  de dígitos, zeros à esquerda, máscara aplicada, qual validação o valor passa ou falha), nunca a
  identidade do titular. "CPF de 11 dígitos com DV válido, sem pontuação, que a máscara rejeitou" tem o
  mesmo valor de evidência que o número real, e nenhum do risco.
- **Por quê**
  Numa rodada real de hotfix o orquestrador mediu o defeito ao vivo com a **planilha real do operador**
  e repassou os valores medidos nas instruções ao agente — era isso que tornava a instrução verificável.
  CPF com dígitos verificadores válidos, telefone, nome e e-mail reais alcançaram **seis** arquivos do
  repositório, incluindo **código de produção** e três arquivos de teste. Só apareceu porque o
  `security-engineer` conferiu os dígitos do CPF em vez de presumir que era placeholder sintético, e
  custou **uma rodada inteira** de implementação só para redigir.
  O próprio achado registra que não foi desatenção do desenvolvedor: **nenhum lugar do pipeline dizia
  que artefato de spec e teste usam dado não atribuível**. E o risco escala — naquela rodada o titular
  era o próprio operador; a próxima execução real usa dado de cliente.
- **Escopo além da issue**
  A issue propôs `docs/TESTING.md` + `sdd-hotfix/SKILL.md`. A caixa em `docs/gates/seguranca.md` foi
  acrescentada por decisão explícita na triagem: os gates são o que os revisores de fato conferem — sem
  uma caixa lá, a regra existe mas não bloqueia.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde. Plugin `1.37.6` (patch).
  Closes #340

(PR #346)

## 1.37.5 — 2026-10-01

- **O que mudou**
  Seção nova em `docs/TESTING.md` — **"Fidelidade do dublê derivado de captura real: página inteira e
  locator estrito"** — com duas regras, espelhadas em uma linha em `backend-developer.md` (item 5d) e
  `code-reviewer.md` (bloco de qualidade de teste):
  - A captura real inclui a **página/resposta inteira**, não só o fragmento de interesse. Capturar só o
  fragmento produz um dublê onde o elemento procurado é único **por construção** — e um teste verde
  contra ele não disse nada sobre o sistema real.
  - Clique/interação em teste usa a **API estrita de locator** (a que falha quando o seletor casa com
  mais de um elemento), nunca o atalho que resolve para "o primeiro que casar". Sem isso, ambiguidade
  de seletor nunca vira erro: vira interação silenciosa no elemento errado, indistinguível de falha
  transitória.
- **Por quê**
  `form button[type='submit']` casava com **2** elementos na página real — o primeiro era a lupa de
  busca do cabeçalho do site, dentro de outro `<form>`. A automação **nunca** clicou no botão da
  feature durante **seis specs**: nenhuma submissão jamais aconteceu, e o desfecho sempre pareceu um
  erro transitório genérico, retentado 5 vezes.
  A causa estava na origem do dublê — a captura era só o fragmento do formulário, sem o cabeçalho do
  site, e ali havia um único `<form>`, então o seletor era inequívoco. **O dado que fecha o
  argumento**: quando o dublê passou a servir a vizinhança do site, os testes de caminho feliz **que já
  existiam** passaram a falhar contra o código antigo, com a mensagem literal dos logs de produção. A
  suíte que já existia teria pego o defeito desde sempre.
  O corolário ficou escrito como regra geral, não só para DOM: captura de fragmento ⟹ o dublê não pode
  decidir ambiguidade de seletor ⟹ a interação precisa ser por locator estrito, para que ambiguidade
  vire falha alta em vez de silêncio.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde. Plugin `1.37.5` (patch).
  Nota de implementação: o item do `backend-developer` entrou como **5d** (estilo já usado nessa lista,
  ao lado de 5b/5c) em vez de renumerar a lista — renumerar colidiria com um `7.` já existente.
  Closes #339

(PR #345)

## 1.37.4 — 2026-10-01

- **O que mudou**
  Dois passos novos em `sdd-hotfix/SKILL.md` (as duas cópias):
  - **3a** — quando a causa raiz é comportamento de **sistema externo** (DOM de terceiro, API de
  parceiro, SDK fechado), a **sequência exata** da sonda que provou a causa — cada passo, na ordem,
  com os intervalos medidos — é registrada no artefato da rodada **e no corpo da instrução passada
  ao agente**, e a implementação **e** o knob de mock têm de reproduzi-la passo a passo. Não a
  paráfrase dela.
  - **4b** — validação ao vivo com **artefato próprio**
  (`coverage/hotfix-<data>-validacao-ao-vivo.md`, append-only: sequência executada, observado antes,
  observado depois, veredito) **antes** de decidir e acionar as revisões do passo 5, sempre que o
  defeito só era observável contra o sistema real. Suíte verde não substitui essa medição, e
  enquanto o veredito não for `não reproduzido` o passo 5 não começa.
- **Por quê**
  Numa rodada real de hotfix a sonda esperava ~250 ms entre preencher o campo e reler o valor — e era
  **esse intervalo** que fazia a correção funcionar, porque a hidratação do framework da página
  reescrevia o input algumas centenas de milissegundos depois. A instrução chegou ao agente como
  "preencher → reler → repetir": o intervalo não chegou ao código, a implementação releu colada na
  escrita, mediu o DOM **antes** do efeito que queria detectar, e passou nos testes. Três rodadas de
  implementação até a validação ao vivo passar, sendo a primeira transição evitável.
  A skill exigia TDD e suíte completa (passos 3 e 4) e **nada** sobre a medição que originou o
  diagnóstico; `docs/POST-MERGE-VALIDATION.md` cobre o teste geral de fim de spec, não rodada de
  hotfix. Quando a causa é comportamento de terceiro, a sonda **é** a especificação executável da
  correção — descrevê-la em prosa perde justamente o detalhe que a faz funcionar.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde. Plugin `1.37.4` (patch — ajuste de instrução, sem
  capacidade nova).
  Closes #338

(PR #344)

## 1.37.3 — 2026-09-27

- **O que mudou**
  `-Encoding UTF8` em todas as leituras de artefato dos scripts `.ps1` de skill — 3 em
  `sdd-status.ps1` e 3 em `sdd-pending.ps1`, nas duas cópias (`.claude/skills/` e
  `plugins/btt-sdd/skills/`). `sdd-gap-report.ps1` já passava o parâmetro e não precisou de
  mudança.
- **Por quê**
  `Get-Content -Raw` sem `-Encoding` usa a codepage ANSI do sistema no Windows PowerShell 5.1
  (o `powershell.exe` padrão do Windows), e **todo artefato do pipeline é um `.md` UTF-8 sem
  BOM**. Cada acento chegava como dois caracteres, então os regexes que reservam um único
  ponto para ele (`Hist.rico de aprova`, `conclu.do`) nunca casavam.
- **Verificação**
  Rodado de verdade no PS 5.1 (`5.1.26100.9549`, codepage `Windows-1252`) contra uma fixture
  UTF-8 sem BOM no formato real dos templates — script em `HEAD` vs. script corrigido:
  | | antes | depois |
  |---|---|---|
  | spec com `Reprovado` no histórico | `Code review (veredito nao identificado - leia o arquivo)` | `Code review - REPROVADO` → `/sdd-implement (corrigir achados)` |
  | spec com `Aprovado` no histórico | `QA (veredito nao identificado - leia o arquivo)` | `QA` → `/sdd-security` |
  O resultado "depois" é idêntico ao que `sdd-status.sh` já devolvia para a mesma fixture —
  paridade entre as duas implementações confirmada, não assumida.
  Em `sdd-pending.ps1` o sintoma era outro, e mais brando do que a issue sugeria: as linhas
  **eram** encontradas (os regexes de seção dessa skill são ASCII de propósito), mas o texto
  extraído saía corrompido — `produÃ§Ã£o` em vez de `produção` — desalinhando as colunas e
  entregando pergunta, contexto e nome de tarefa corrompidos ao agente que leu a saída.
  Também verificado que **não há regressão com BOM**: a mesma fixture regravada com BOM
  continua correta depois da mudança, sem `U+FEFF` residual no início do conteúdo. No
  PowerShell 7+ o parâmetro é aceito e não muda nada, então serve as duas versões sem
  condicional.
- **Sincronia e versão**
  `python scripts/check-plugin-sync.py` verde (59 pares comparados). Como a mudança toca
  `plugins/btt-sdd/`, versão do plugin de `1.37.2` → `1.37.3` (patch — correção de
  comportamento, sem capacidade nova).
  Cada script ganhou um comentário no topo registrando o *porquê* do parâmetro, para a
  próxima leitura de arquivo nascer com ele.
  Closes #334

(PR #337)

## 1.37.2 — 2026-09-26

  Duas das cinco specs de um projeto real vinham com `Revalidar: sim` **sem revalidação pendente nenhuma**. Quem confia na coluna procura uma etapa em aberto que não existe; quem conhece o projeto aprende a ignorar a coluna — que é o único jeito de a flag legítima passar batida.
- **Três defeitos, no mesmo bloco**
  **1. A frase casada negava a revalidação.** `grep -qi 'requer revalida'` casava `Nenhuma — nenhuma etapa a jusante **requer revalidação**` — que é exatamente a redação que `trd.template.md` induz ao pedir "etapas que requerem revalidação". **Seguir o template produzia o falso positivo.**
  **2. O alvo era identificado errado.** `grep -qiw 'TRD'` sobre a linha inteira pegava o TRD quando ele era só a *causa*: em `**Segurança requer revalidação.** TRD revisão 9 redesenhou ConfirmOutcomeAsync`, o sujeito é Segurança. Sintoma colateral: a coluna guardava uma string só e a última etapa iterada vencia, então nem a contagem de flags era confiável.
  **3. Os cinco artefatos de revisão não tinham caminho de resolução.** A flag só era testada contra o checkbox `Aprovado por`, que só PRD e TRD têm. Uma revisão que refez o trabalho registra isso como **linha de log** — estruturalmente invisível ao script. No caso relatado, a linha *imediatamente seguinte* à flag era a revalidação.
- **O que muda**
  As quatro correções que a issue sugeriu:
  1. **O alvo é o artefato citado colado em "requer revalidação"**, não qualquer sigla na linha. Resolve o alvo e, de graça, descarta a negação ("a jusante requer revalidação" não tem artefato antes) e as menções em que TRD/PRD são só causa.
  2. **Linha de log posterior assinada pelo agente da etapa resolve a flag** (`code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`). Comparação de data **estrita** de propósito: a granularidade é de dia, e resolver uma flag por engano é silencioso, enquanto deixá-la aberta é visível e acionável.
  3. **Os alvos acumulam** — `sim (TRD, QA)` em vez de a última etapa sobrescrever a string.
  4. **Uma linha pode carregar mais de uma flag**, e todas são lidas. Isso saiu da própria verificação: a primeira versão parava no primeiro alvo e a fixture de regressão pegou.
  Mudança de semântica deliberada: a coluna passa a nomear a etapa que **precisa** ser revalidada, não aquela em cujo log a flag foi escrita. É o que a pergunta "revalidar o quê?" pede — antes, uma flag no log do PRD apontando para o TRD era reportada como `sim (PRD)`.
- **Verificação**
  Cinco fixtures, nas duas implementações:
  | Fixture | Antes | Depois |
  |---|---|---|
  | flag resolvida por linha posterior no próprio log (**caso A** da issue) | `sim (Segurança)` | `não` |
  | frase negada, redação induzida pelo template (**caso B**) | `sim (TRD)` | `não` |
  | flag legítima em aberto (regressão) | `sim (PRD)` — etapa errada | `sim (TRD)` |
  | resolvida por reaprovação formal do TRD (regressão, caminho que já existia) | `não` | `não` |
  | duas flags na mesma linha | `sim (Code review)` — uma só, e a etapa errada | `sim (TRD, QA)` |
  Também rodadas as fixtures da #333 para confirmar que nada regrediu naquele caminho.
- **Nota de escopo**
  O `.ps1` só roda contra fixture **com BOM**: `Get-Content -Raw` lê UTF-8 como ANSI no Windows PowerShell 5.1 (**#334**, pré-existente). As três chamadas ficam **sem** `-Encoding` neste PR de propósito — é o escopo da #334, e corrigir uma só deixaria o arquivo inconsistente consigo mesmo. Este bloco em particular não depende de acento (`aprovad[oa] por`, `requer revalida`, nomes de agente são todos ASCII), então a correção funciona mesmo com a leitura errada.
  Closes #332

(PR #336)

## 1.37.1 — 2026-09-26

  `/sdd-status` mandava rodar `/btt-sdd:sre` numa spec **concluída** — exatamente a ferramenta que alguém consulta para saber o que falta, ensinando o usuário a desconfiar da coluna.
- **Causa**
  `latest_verdict` guardava cegamente a **última** linha da tabela "Histórico de aprovações por fatia". Um hotfix que pula formalmente uma etapa acrescenta `| hotfix-... | #116 | Pulado (justificado) | ... |`, e `Pulado (justificado)` não casa `aprovado` nem `reprovado` → fallback "veredito não identificado". O `Aprovado com ressalvas` real, duas linhas acima, nunca era alcançado.
  O dado está **correto** — os hotfixes pularam SRE legitimamente (`skills/hotfix/SKILL.md`: SRE só com impacto de infra/CI/dependência). Quem erra é o leitor.
- **O que muda**
  Ambas as correções que a issue sugeriu, porque juntas dão o resultado certo:
  1. **Sobe a tabela até a linha mais recente que carregue veredito**, em vez de parar na última. Mantido o descarte da linha separadora (`|---|---|`).
  2. **`Pulado` vira valor conhecido no classificador**, com estado próprio e sem próximo comando — coerente com o que a #163 fez para `## Decisão: QA pulado`. A assimetria que a issue aponta (mesma decisão em dois formatos, só um entendido) fecha.
  Duas decisões de implementação que valem registro:
  - O ramo `Pulado` vem **depois** de aprovado/reprovado. Uma linha pode dizer `| F-1 | #100 | Aprovado | ... | UX review pulado nesta fatia |` — aí o veredito que vale é o `Aprovado`. Há fixture de regressão para isso.
  - O rótulo é `"<Etapa>: etapa pulada (justificada)"`, não `"<Etapa> pulado"`: o gênero do rótulo varia (`SRE`, `Segurança`, `Code review`) e só o núcleo fixo concorda.
- **Verificação**
  Sem suíte no repo — quatro fixtures sintéticas, rodadas nas **duas** implementações, antes e depois:
  | Fixture | Antes | Depois |
  |---|---|---|
  | `Pulado` depois de `Aprovado com ressalvas` (o caso da issue) | `SRE (veredito não identificado)` → `/sdd-prd` | `SRE (com ressalvas)` → `(pipeline concluído)` |
  | `Pulado` como única entrada | `Segurança (veredito não identificado)` → `/sdd-prd` | `Segurança: etapa pulada (justificada)` → `(nenhum — decisão registrada)` |
  | `Aprovado` mencionando "pulado" na célula (regressão) | `QA` → `/sdd-security` | idêntico |
  | `Reprovado` (regressão) | `Code review — REPROVADO` | idêntico |
  `.sh` e `.ps1` produzem saída equivalente nos quatro.
- **Achado adjacente, já registrado**
  A verificação do `.ps1` só passou com fixture **gravada com BOM**: `Get-Content -Raw` lê UTF-8 como ANSI no Windows PowerShell 5.1, então `Histórico` vira `HistÃ³rico` e a seção nunca é encontrada — todas as quatro fixtures davam "veredito não identificado" **também no HEAD**. Bug pré-existente, independente desta correção, e de alcance maior (afeta todo `/sdd-status` no PowerShell padrão do Windows). Registrado como **#334**, não corrigido aqui.
  Closes #333

(PR #335)

## 1.37.0 — 2026-09-26

  Sete blocos idênticos em 3+ agentes/skills somavam **~39k caracteres duplicados** — ×2 pela cópia do plugin. O custo não é estético: a #309 precisou editar o mesmo parágrafo em 5 agentes, a #301 inseriu o mesmo bloco em 8 skills × 2 cópias, e a #312 anexou um parágrafo a só 4 dos 8 agentes que tinham o bloco de `PROJECT-CONVENTIONS` — **a duplicação já tinha produzido divergência acidental**.
- **O que muda**
  - **`docs/AGENT-PREAMBLE.md`** e **`docs/SKILL-PREAMBLE.md`** (dois arquivos, porque um agente resolve o caminho por onde foi carregado e uma skill pelo `Base directory` da invocação).
  - Cada agente/skill passa a ter **uma linha de ponteiro** no topo, antes de qualquer seção. O ponteiro é auto-resolvível de propósito: o preâmbulo é o texto que explica onde os docs ficam, então não pode depender de si mesmo para ser encontrado.
- **O critério de extração**
  Da issue, e vale a pena repetir porque é o que evita extração cega:
  - **Sai** o que é contexto/resolução — modo de falha **ruidoso** (não leu → erra o caminho → percebe).
  - **Fica inline** o que é proibição comportamental — modo de falha **silencioso**. "Confirme que está na branch do PR sendo revisado" (338 chars, 3×) continua copiado nos três agentes de revisão.
- **Duas unificações deliberadas (não mecânicas)**
  1. O parágrafo `[medido]`/`[inferido]` da #312 passa a valer para os 11 agentes em vez de 4 — era exatamente a divergência acidental que a issue aponta.
  2. `docs/PROJECT-CONVENTIONS.md` passa a ser lido também por `product-design`, `codebase-archaeologist` e `tech-writer`.
  Também absorvidas: as variantes curtas de `ux-designer`, `sdd-ux-review` e `sdd-project-conventions` (o preâmbulo é o superset — `docs/DESIGN-SYSTEM.md`, que só a variante do `ux-designer` citava, está preservado).
  `repo-issues` fica de fora: é a única skill que nunca teve a seção, e só roda dentro deste repositório, onde `docs/` é sempre o local.
- **Medição**
  | | chars |
  |---|---|
  | agentes + skills, antes | 866.042 |
  | agentes + skills, depois | 795.297 |
  | preâmbulos novos (×2 cópias) | +11.918 |
  | **líquido** | **-58.827** |
  Blocos repetidos 3+ caem de 8 para 3, e os 3 restantes são os dois ponteiros novos (intencionais) mais o bloco 8 (preservado por decisão).
- **Verificação**
  - `check-plugin-sync.py`: 59 pares, as duas cópias em dia.
  - Frontmatter YAML de todo agente e skill íntegro.
  - Nenhum resíduo dos blocos extraídos fora dos preâmbulos; nenhum heading ficou sem corpo.
  Versão do plugin: `1.36.0` → `1.37.0`.
  Closes #329

(PR #331)

## 1.36.0 — 2026-09-26

  `docs/QUALITY-GATES.md` tinha 662 linhas e era a referência única citada por todos os 11 agentes e por quase toda skill — então todo agente carregava o checklist inteiro para usar 3 parágrafos.
- **O que muda**
  - **`docs/QUALITY-GATES.md` vira índice** (67 linhas): mapa por etapa, tabela "quem lê o quê", e "seção antiga → arquivo" para as citações escritas antes da divisão.
  - **`docs/gates/*.md`**: 13 arquivos, um por etapa — `governanca`, `licoes`, `status-de-tarefas`, `baseline`, `prd`, `trd`, `implementacao`, `code-review`, `ux`, `qa`, `seguranca`, `sre`, `merge`. Cada gate em exatamente um lugar.
  - **Cada agente declara a lista fechada** do que lê: `governanca` + `licoes` (transversais) + os da etapa dele. 2 a 4 arquivos, não 662 linhas.
  - **137 referências reapontadas** — as que nomeavam a seção e também as que nomeavam só a regra ("Nenhum agente aprova/reprova o próprio trabalho", "limite de 3 tentativas") e por isso mandavam o leitor de volta ao índice.
  - `scripts/check-plugin-sync.py`: pareamento recursivo de `docs/` (senão os gates novos ficariam de fora do gate de sincronia) e `gates/<n>.md` como token normalizado, para a adaptação `... do pipeline` do scaffold não contar como deriva.
- **Verificação**
  - Conteúdo dos 13 arquivos **idêntico** ao original nas duas cópias, comparado com as referências normalizadas (52.970 e 52.962 caracteres, zero divergência).
  - `check-plugin-sync.py`: 57 pares, as duas cópias em dia.
  - Frontmatter YAML de todos os agentes e skills íntegro (verificado — já foi quebrado por um script de reflow nesta mesma linha de trabalho).
  - Zero link quebrado: todo `docs/gates/X.md` citado existe nas duas cópias, e os 13 links do índice resolvem.
  Versão do plugin: `1.35.0` → `1.36.0` (mudança estrutural na distribuição dos docs).
  Closes #328

(PR #330)

## 1.35.0 — 2026-09-26

- **Por quê**
  A **#288** resolveu a metade **de entrada** do problema: o `trd.template.md` manda a tarefa de investigação vir **primeiro**, antes do primeiro código contra o contrato suposto. Falta a metade **de estoque** — o que fazer com as premissas não validadas que **já existem** e cujos consumidores crescem a cada fatia que faz a coisa certa.
  Formulação do `security-engineer` que promoveu isso a lição (**4 ocorrências em 3 features**):
  > A tarefa que validaria a premissa **não pertence a fatia nenhuma** — ela não entrega critério de aceite de nenhum PRD —, então fica indefinidamente `pendente` enquanto seus consumidores se multiplicam, e a própria issue que a rastreia envelhece subcontando o raio de impacto.
  Toda skill do pipeline organiza trabalho **por fatia**, e fatia é definida por entrega de valor verificável contra o PRD. Uma tarefa cujo produto é "agora sabemos se a suposição X é verdadeira" não cabe em nenhuma: some da tabela de VALIDAR DEPOIS quando a spec de origem encerra, e nunca esteve numa decomposição.
- **O que mudou**
  - **`skills/pending/SKILL.md`, passo 1b** — terceira lista. O script auxiliar não a enxerga porque a **fonte é issue do GitHub, não artefato**: `gh issue list --label premissa-nao-validada`, **ordenada por número de consumidores**. Sem essa ordenação a priorização não vê que uma delas **dobrou de tamanho na última fatia**.
  - **`agents/architect.md`, item 1c** — a issue da tarefa de investigação nasce com o label e com a contagem de consumidores no corpo.
  - **`agents/security-engineer.md`** e **`code-reviewer.md`** — ao **propagar** um controle apoiado em premissa não validada, a mesma rodada atualiza a issue com o **novo número de consumidores**. Custa uma linha.
  Nomeei a assimetria que torna o padrão invisível: revisar *"esta propagação está correta?"* custa pouco e dá verde; revisar *"quantos consumidores esta premissa tem **agora**?"* ninguém faz, porque não está em checklist nenhum.
  Mais duas consequências práticas que a issue documenta com caso real:
  - **Direção fail-safe ao propagar**: o pior caso de um seletor/marcador errado deve ser um **no-op**, nunca um desfecho terminal novo — e dizer no comentário qual é a direção. Num conjunto fechado de quatro sinais, três falhavam na direção segura e **um** falhava invertido; só ficou visível porque alguém perguntou.
  - **Aproveitar medição ao vivo que já esteja acontecendo por outro motivo**: foi assim que a única evidência empírica sobre um seletor apareceu — em quatro specs, praticamente de graça, durante uma medição feita para outra coisa.
- **Generalizável**
  Nada é específico de stack: vale para seletor de DOM de terceiro, nome de campo de SSO, código de erro de API não documentada, limite de SaaS, formato de webhook.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.34.0` → **`1.35.0`** (minor — lista nova em `/sdd-pending` e convenção de label).
  Closes #308

(PR #327)

## 1.34.0 — 2026-09-26

- **Por quê**
  As seções 9, 13 e 14 do TRD **não são prosa: são contrato lido a jusante.**
  - **9** — onde QA e SRE conferem o que o mundo externo enxerga.
  - **13** — fonte do Status que `/sdd-pending` e `/sdd-status` reportam, e de onde a fatia seguinte tira o que implementar.
  - **14** — o que o `sre` lê para decidir semver.
  Uma revisão que muda comportamento (uma fatia acrescentou campo ao contrato de log) ou que **refuta uma premissa** toca necessariamente essas seções — e hoje a reconciliação depende inteiramente de alguém lembrar.
- **O custo medido**
  Numa fatia real, **4 dos 12 achados** de code review eram higiene documental do TRD. Um deles foi classificado pelo próprio `code-reviewer` como *"mesma classe"* de um achado da fatia anterior (rastreabilidade unidirecional: a correção registrou a divergência no XML doc do código, mas não no item correspondente do TRD) — **segunda ocorrência da mesma classe na mesma spec**.
  A trilha de code review daquela fatia (30m48s de revisão + 45m37s de correção + 26m55s de reverificação = **1h43m**) saiu **mais cara que a própria implementação** (1h21m19s). E um dos achados tinha potencial de contaminar uma fatia futura que ainda não tinha começado.
- **O que mudou**
  - **`skills/amend/SKILL.md`, passo 3** (onde a revisão é gravada): quatro verificações fechadas e baratas —
  1. reler a **linha 1** do arquivo (pega corrupção acidental por edit);
  2. reconciliar a **seção 9** se o contrato observável mudou — é ela, não a 7, que as etapas seguintes leem como contrato;
  3. quando uma premissa é refutada ou restringida, varrer o documento pelas afirmações que ela sustentava — seções 7 e 13, **incluindo linhas de tarefas de fatias ainda não iniciadas**;
  4. atualizar a linha da fatia na **seção 14** e a coluna Status na **13**.
  - **`skills/implement/SKILL.md`**: ponteiro para essa passada no ponto em que o TRD é editado, antes da promoção de Status.
  - **`docs/QUALITY-GATES.md`**, bloco do `code-reviewer`: item de checklist — para a conferência ser **cobrada**, não só recomendada.
  Não é etapa nova: é um parágrafo de checklist no passo que já bumpa a revisão.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.33.3` → **`1.34.0`** (minor — passo novo de conferência no fluxo de emenda).
  Closes #305

(PR #326)

## 1.33.3 — 2026-09-26

- **Por quê**
  Quando uma pendência de privacidade é resolvida por **aceitação** — "o usuário assume o risco, e a limitação vai para a documentação do operador" —, a pendência é marcada resolvida e sai de `/sdd-pending`. A metade que sobrou (escrever a consequência onde o operador lê) **some exatamente no momento em que o risco vira permanente**.
- **Três ocorrências, e a assimetria é instrutiva**
  | # | Condição declarada | Estado |
  |---|---|---|
  | 1 | aceite de compartilhamento marcado em nome do titular sem confirmação humana → "documentar essa nuance" | **pendente há 4 specs** |
  | 2 | README descrevia arquitetura de privacidade anterior → documentar | **resolvida na mesma fatia** |
  | 3 | operar sem sessão autenticada → "a limitação vai para a documentação do operador" | **não cumprida** |
  **A única que fechou foi a que tinha dono dentro do próprio PR.** As duas que descrevem consequência para **dado de terceiro** (CPF, nome, telefone de clientes que não participaram de decisão nenhuma) não tinham dono — e a mais antiga já atravessou **quatro specs**.
  Medido por `grep` no HEAD da última fatia: nada relevante no README. Enquanto isso o README apresentava a mesma característica como **capacidade** em três lugares — um deles **dentro** da seção "Limitações conhecidas", e ainda assim redigido como tranquilização.
- **Por que é estrutural, não desleixo**
  A condição fica registrada no `security-review.md`, que é artefato de **revisão**: lido antes do merge, por quem revisa, e por ninguém depois. O operador lê o **README** — outro arquivo, escrito por outra etapa. Como a decisão "fecha" a pendência no artefato de revisão, o item deixa de aparecer em `/sdd-pending`.
- **O que mudou**
  - **`agents/security-engineer.md`, item 3b** — a recíproca do 3a, que já resolvia o caminho de **criação**: ao **resolver** com "aceitar + documentar", desdobrar a parte de documentação num item próprio de VALIDAR DEPOIS, com (a) a redação mínima já escrita, (b) o arquivo/seção de destino e (c) o dono. **Só o item de decisão fecha.**
  - **`agents/security-engineer.md`, item 3c** — na revisão da **última fatia**, **medir** (`grep` pelos termos da consequência) se as condições de documentação de decisões anteriores foram cumpridas, em vez de presumir que "o usuário decidiu, logo está tratado". Foi literalmente assim que o achado apareceu.
  - **`skills/sre/SKILL.md`, passo 5b** — ao acionar o `tech-writer` na última fatia, **passar explicitamente** a lista de VALIDAR DEPOIS de tipo documentação abertos na spec e nas anteriores. É a única etapa com dono natural para texto de README, e **não recebe a tarefa a menos que alguém a nomeie**.
  - **`agents/tech-writer.md`** — consequência assumida vai para **"Limitações conhecidas", nunca "Requisitos"** (o operador lê a segunda como configuração e a primeira como aviso), e conferir se as frases existentes sobre a mesma característica não contradizem o parágrafo novo.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.33.2` → `1.33.3` (patch).
  Closes #313

(PR #325)

## 1.33.2 — 2026-09-26

- **Por quê**
  Uma frase **inferida** escrita dentro de um artefato de investigação **medida** herda a autoridade do artefato inteiro. Nenhum agente a jusante a questiona — o documento existe justamente para ser a fonte do que foi observado ao vivo.
- **O caso, do começo ao fim**
  **Origem.** A tarefa T-1 (criada exatamente como o item 1c manda) produziu um artefato excelente, que mediu o DOM real do modal e derrubou **quatro** suposições do TRD. Numa seção de nota operacional, duas sentenças do mesmo parágrafo:
  > **O perfil de Chrome dedicado está deslogado do Mercado Livre.** Uma execução real da automação hoje terminaria em `NotAuthenticatedException` já na primeira linha.
  A primeira é **medida**. A segunda é **inferência pura** — ninguém tinha rodado nada deslogado. Sem marcação, mesmo tom afirmativo.
  **Propagação.** Virou restrição em dois artefatos a jusante, por **dois agentes diferentes**: o `architect` a incorporou numa seção do TRD, e o `sre` abriu uma ressalva sobre ela — "login manual do operador" virou pré-requisito do roteiro de validação pós-merge. Nenhuma das duas etapas a marcou como hipótese nem tentou medi-la, apesar de a medição custar poucos minutos com ferramenta que o projeto já usava.
  **Refutação.** Só caiu porque **o usuário disse "isso não bate com o que eu vejo"**. A medição subsequente derrubou a ressalva inteira, reescreveu o roteiro de validação pós-merge (que deixou de exigir login manual e passou a poder confirmar o critério de aceite central sem submeter nada) e, de quebra, produziu a primeira evidência empírica em quatro specs sobre outro seletor.
- **O que faltava**
  O item **6f** já exige marcar `[medido]`/`[não medido]` — mas só na **seção 12 do TRD** e só para "comportamento concreto de biblioteca de terceiro ou de runtime". O próprio 6f antecipa o mecanismo que falhou aqui: *"a mesma frase sem marcação é lida como fato estabelecido — inclusive quando escrita com hedge, que faz o texto parecer análise prudente e desarma a verificação."*
  Falta aplicar a mesma disciplina onde ela é **mais** necessária: o artefato de investigação é o único documento da spec cuja autoridade vem de ter sido medido.
- **O que mudou**
  - **`agents/architect.md`, item 1c**: marcação **por afirmação** dentro do artefato — `[medido]` com o comando/caminho que produziu a observação, `[inferido]` com o que precisaria ser medido. Com a nota de que seção de "nota operacional"/"consequência prática" **não** fica de fora da regra: é justamente onde a inferência se esconde. E, ao emendar o TRD, uma afirmação `[inferido]` entra como **pendência ou premissa marcada, nunca como restrição de desenho**.
  - **`agents/{sre,code-reviewer,security-engineer,qa-engineer}.md`**: ao citar um artefato de investigação como base de uma ressalva, verificar a marcação — e, quando a medição for barata e o ambiente estiver à mão, **propor medi-la** em vez de carregar a ressalva por três fatias.
  - **`docs/QUALITY-GATES.md`**: item de checklist.
  Generalização do que a **#268** instituiu restrito ao `architect` + seção 12 + biblioteca de terceiro.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.33.1` → `1.33.2` (patch).
  Closes #312

(PR #324)

## 1.33.1 — 2026-09-26

- **Por quê**
  `code-reviewer` e `qa-engineer` já tratam a tabela de mutações do autor como **hipótese, não fato**, e já mandam reexecutar um subconjunto e inventar mutações próprias. O que faltava nas duas pontas é mais fino: **reexecutar a mutação relatada e ver que ela morre não é suficiente.**
  Uma mutação que quebra o fluxo **antes** do ponto sob teste mata o teste por qualquer asserção anterior, e o vermelho resultante é indistinguível do que se queria provar.
  A ironia que fecha o caso: **a prova da correção tinha o mesmo defeito que o critério de teste do TRD proíbe** — passar/falhar por um motivo que não é o que se está medindo. Exatamente o defeito que o achado bloqueante daquela fatia era.
- **O que mudou**
  - **`agents/code-reviewer.md`** e **`qa-engineer.md`**, na heurística de mutação que já existe: conferir **qual** asserção matou. Se morreu por uma asserção anterior ao ponto sob teste, a mutação não prova nada sobre aquele ponto — construir a **mutação complementar**, a que mantém o fluxo íntegro e ataca o **modo de falha oposto** ("a asserção nova ficou tolerante demais?"). O par das duas é que responde; nenhuma sozinha responde.
  - **`agents/backend-developer.md`** e **`frontend-developer.md`**: não mencionavam mutação **em lugar nenhum** — e é justamente o formato do relato que torna o engano invisível. Ao reportar mutação como evidência de discriminância, informar **a asserção que falhou (arquivo:linha) e a mensagem**, nunca só "mutação X, N testes morreram". Se a asserção que falhou não é a que a mutação pretendia exercitar, **dizer isso**: é informação, não demérito.
- **Generalizável**
  Vale para qualquer projeto que use mutação como evidência de discriminância, independente de stack: a informação que falta é sempre a mesma (qual asserção, qual mensagem), e o modo de falha é sempre o mesmo (a mutação quebra cedo demais e mata o teste antes de alcançar o que se quer provar).
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.33.0` → `1.33.1` (patch).
  Closes #306

(PR #323)

## 1.33.0 — 2026-09-26

- **Por quê**
  Duas coisas que `docs/TESTING.md` **não dizia** — busca por "relógio", "constante de tempo" e "flaki" no arquivo não retornava nada —, ambas medidas ao vivo.
  ### 1. Ajustar a constante de tempo não é correção
  Demonstrado ponta a ponta: **a mesma asserção, com a constante 20× maior, caiu no primeiro CI sob contenção.** As duas correções legítimas são **relocar** a asserção para o nível em que ela não depende de tempo, ou **trocar a dependência de relógio por um sinal explícito** controlado pelo teste.
  ### 2. Classificar antes de contar
  Uma entrada de lição com **27 ocorrências** somava duas populações distintas:
  | | Assinatura | Corrigível? |
  |---|---|---|
  | **(a) Contenção** | **timeout** no rastro | não por reescrita — é ambiente |
  | **(b) Asserção presa a relógio** | **falha de asserção, sem timeout** — valor que depende de quanto tempo algo levou | **sim**, e comprovadamente |
  **Cerca de um terço** das 27 era (b). Um contador que soma as duas faz a instabilidade parecer intratável e **desencoraja a correção da metade que tem conserto**. A assinatura de (b) é fácil de perder: várias ocorrências se manifestaram como falha de contagem de tentativas, e procurar só por "timeout" no rastro deixa passar.
- **O dado de custo que sustenta a preferência pelo unitário**
  Medido no CI: **22 testes unitários novos custaram 0 s** de suíte (490 ms contra 492 ms, dentro do ruído); **18 de integração custaram 36 s**. 316 unitários rodam em 451 ms, determinísticos.
- **O que mudou**
  - **`docs/TESTING.md`**: seção nova "Instabilidade de teste: classe da asserção, não constante de tempo" — as duas correções legítimas, a classificação (a)/(b), e a regra de que asserção sobre valor derivado de tempo **nasce no nível unitário**.
  - **`agents/code-reviewer.md`** e **`qa-engineer.md`**: ao avaliar a correção de um teste que era instável, perguntar se mudou a **classe** ou só a **constante**.
  - **`agents/backend-developer.md`** e **`frontend-developer.md`**: teste novo que assevera valor derivado de tempo nasce no unitário.
  Nada disso é específico de stack: qualquer projeto com testes que atravessam navegador, rede ou processo acumula asserções que dependem de tempo de parede, e o reflexo universal é "aumenta o timeout".
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.32.1` → **`1.33.0`** (minor — seção nova em `TESTING.md` com regra de escrita de teste).
  Closes #307

(PR #322)

## 1.32.1 — 2026-09-26

- **Por quê**
  Complemento à #284, que estabeleceu a receita de short-circuit. **A receita está certa** — faltava registrar **o que ela leva junto**.
  O `sre` de uma fatia requantificou o custo e mediu uma contrapartida que ninguém tinha previsto:
  > Os dois runs vermelhos desta fatia rodaram em commits só de documentação, **sobre um código que já tinha passado verde**. Sob a proposta de SRE-1, os dois teriam sido pulados — o código era byte-idêntico a um SHA que já passou, que é exatamente a condição de short-circuit. E esses dois runs foram **os que acharam F2-1**, o achado bloqueante do code review.
  F2-1 é uma asserção presa a relógio (`Expected: ["Shopping Morumbi"] / Actual: ["S", "Shopping Morumbi"]` — o *debounce* de 75 ms do mock disparando no meio de uma digitação de 25 ms/tecla). Ela **não falha sempre**: falha sob contenção.
  Rodar a mesma suíte 4 vezes sobre o mesmo código **é** um teste de repetição, e teste de repetição acha asserção instável. O pipeline vinha se beneficiando disso sem saber.
- **O que mudou**
  - **`agents/sre.md`**, logo depois da receita: **nunca oferecê-la sozinha**. Ao propô-la, propor no mesmo movimento um substituto **deliberado** — tipicamente um `schedule` rodando a suíte de integração completa na branch base, N vezes por dia, **fora do caminho crítico de qualquer PR**. Custa o mesmo tempo de runner que hoje se gasta por acidente, e produz **série temporal em vez de anedota**.
  - **`docs/QUALITY-GATES.md`**, antes da nota de custo de CI: registra que as execuções redundantes funcionam como amostragem acidental, e que suprimi-las exige substituto deliberado.
- **Por que isso não contradiz a #284 nem a #300**
  A receita continua certa, e o texto diz por quê: usar o caminho crítico de cada push de documentação como amostrador é **caro** (~13 min por amostra), **não é intencional**, **não é controlável** e **bloqueia o merge quando acha algo**. O ponto é que adotá-la sozinha remove a única amostragem repetida que o repositório tem — num projeto cuja lição mais cara (**27 ocorrências** catalogadas) é justamente sobre estabilidade de suíte.
  Vale para a cadência `ci-antes-do-merge` da #300 pelo mesmo motivo: ela suprime as mesmas execuções. Quem for aplicar qualquer das duas em outro projeto lia só o lado do desperdício, aplicava, e meses depois teria uma suíte cuja instabilidade só aparece no merge de uma fatia grande — sem entender que trocou um amostrador barato-mas-acidental por nenhum.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.32.0` → `1.32.1` (patch).
  Closes #303

(PR #321)

## 1.32.0 — 2026-09-26

- **Por quê**
  O mecanismo de escalonamento (#140, #151) **funciona**: na 3ª ocorrência o agente *oferece* resolver via `AskUserQuestion`. O que ele não tem é **memória**. A oferta é refeita a cada fatia, a resposta anterior não é registrada em lugar nenhum, e a pendência nunca converge — só acumula ocorrências.
- **Três entradas, todas muito além do limiar, todas paradas**
  | Entrada | Ocorrências | Estado |
  |---|---|---|
  | `commitlint-nao-obrigatorio` | **5ª** — a spec inteira mergeada sob um gate de título que nunca foi obrigatório, **incluindo a fatia que publicou a quebra de contrato** | "oferecido e não aplicado" em F-1, F-2 e F-3 |
  | `dotnet-format` | **6ª spec** consecutiva | gate de lint segue com `continue-on-error: true` |
  | `flakiness-integracao-sob-carga` | **29** | "mitigação ainda não decidida" |
  O caso do `commit-lint` é o mais ilustrativo: nesta rodada o agente **reuniu os dados que resolveriam a dúvida** — mediu que o check custa 3 s, mostrou que não interage com a cadência nova, e derrubou a objeção plausível ("torná-lo obrigatório aumenta a superfície de bloqueio") com um incidente real de Actions do mesmo dia. Sobrou um único efeito colateral a decidir. Nada disso fica registrado como "já perguntado, faltando X" — na próxima spec o próximo agente recomeça do zero.
  Palavras do artefato: *"Continua acima do limiar de escalonamento, o que me autoriza a oferecer e nunca a aplicar sem aprovação explícita — e eu não apliquei."* É a leitura correta do manual. E é a terceira vez seguida que a mesma frase é escrita sobre o mesmo item.
- **O que faltava**
  A entrada registra **ocorrências** (eixo de frequência), nunca **decisão**: se a oferta já foi feita, quando, o que o usuário respondeu, e o que falta para converter. Sem isso, uma recusa deliberada é **indistinguível** de uma pergunta que nunca chegou até ele.
- **O que mudou**
  `docs/QUALITY-GATES.md`, seção "Lições aprendidas recorrentes":
  - Campo **"Escalonamento"** na entrada, append-only, uma linha por oferta: data, quem ofereceu, o que foi oferecido, resposta (`aceito`/`adiado`/`recusado`/`sem resposta`). Acrescentado também à enumeração do "Formato de entrada".
  - Quem reconfirma **lê o campo antes de ofertar**, e **não repete oferta idêntica** já adiada ou recusada — reofertar exige **fato novo**: objeção derrubada por medição, agravamento do impacto, ou classe de ocorrência nova.
  - **`recusado` fecha o eixo de decisão**: continua contando ocorrências, para de escalar, motivo escrito.
  - **`adiado`/`sem resposta` em entrada com 5 ocorrências vira issue rastreada** no repositório do projeto — a saída que tira o item do artefato de revisão, onde é relido por todo mundo e resolvido por ninguém.
  Mesma família das #140 e #151, que criaram o **gatilho** da oferta; esta é sobre o que acontece **depois** dela.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova. Versão: `1.31.3` → **`1.32.0`** (minor — campo novo no formato de entrada e um segundo patamar de escalonamento).
  Closes #314

(PR #320)

## 1.31.3 — 2026-09-26

- **Por quê**
  A seção "Lições aprendidas recorrentes" prevê **três** movimentos para uma entrada: criar (2ª ocorrência), acrescentar ocorrência, e corrigir a prosa quando a métrica se mostra mal atribuída. Não prevê o quarto: **a entrada deixar de valer porque o mundo mudou de forma deliberada.**
- **O caso medido**
  `L-2026-09-21-pr-mergeavel-mas-marcado-draft` existia desde a spec `0001` e acumulou **6 ocorrências**: "PR mergeável mas ainda marcado como draft" tratado como descuido de fluxo.
  Em 2026-09-26 o projeto adotou `ci-antes-do-merge` (#300). A partir daí **`isDraft: true` durante a fatia é o mecanismo** que suprime a suíte cara — e um PR que *não* estivesse em draft durante a implementação passaria a ser o anômalo.
  Na primeira passagem da revisão de F-3 o agente **registrou a 7ª ocorrência**. Só ao reauditar contra o `ci.yml` novo percebeu a inversão, desfez o registro, e teve de **inventar** a marcação "obsoleta para este projeto" na hora — preservando as 6 ocorrências históricas e apontando o sucessor à mão.
- **O que mudou**
  `docs/QUALITY-GATES.md`, seção "Lições aprendidas recorrentes":
  - **Antes de acrescentar uma ocorrência**, conferir se `docs/PROJECT-CONVENTIONS.md` tornou *esperado* o comportamento que a entrada trata como defeito. Se tornou, não incrementa — marca.
  - **Estado `obsoleta`** no formato da entrada, com três campos: desde quando, por qual convenção/decisão, e **o que sobrevive** dela (no caso acima sobreviveu a parte de método: `mergeStateStatus` é opaco e `isDraft` precisa ser consultado como campo próprio — só que agora para saber se a suíte rodou). Ocorrências históricas **preservadas, nunca apagadas**: elas aconteceram, e sob o regime antigo o diagnóstico estava certo. Quando a obsolescência cria um risco novo, a entrada aponta o **sucessor** pelo ID.
  Nomeei a assimetria de custo que torna o padrão invisível, porque é ela que explica por que o erro acontece: contar mais uma ocorrência é barato e invisível; perceber que a entrada inteira caducou exige reauditar a premissa — exatamente o que não se faz quando a entrada "já está estabelecida", e uma entrada com muitas ocorrências acumula autoridade.
- **Por que isso tende a crescer**
  O padrão aparece onde o pipeline ganhou **opt-in por projeto**: a #287 tornou `PROJECT-CONVENTIONS.md` legível por todos os agentes, e a #300 foi o primeiro opt-in de comportamento. Quanto mais convenções por projeto, mais lições genéricas podem deixar de valer localmente.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova. Versão: `1.31.2` → `1.31.3` (patch).
  Closes #310

(PR #319)

## 1.31.2 — 2026-09-26

- **Por quê**
  O `sre` argumentou economia de CI em **duas rodadas seguidas** de uma spec usando só tempo de parede e bloqueio de merge. O eixo mais direto — **dinheiro** — só apareceu na terceira rodada, depois de o usuário já ter resolvido o problema por fora do pipeline. O agente não tinha instrução nenhuma para olhar esse eixo, e ele custa dois comandos.
  Palavras do próprio artefato: *"em F-1 e F-2 eu argumentei SRE-1 por tempo de parede e por bloqueio de merge; o eixo de custo monetário eu simplesmente não tinha olhado, e ele é o mais direto de todos."*
- **O que a medição completa mostra**
  | Fatia | Runner Windows desperdiçado |
  |---|---|
  | F-1 | ~50 min |
  | F-2 | ~83 min |
  | F-3 | 73 min (65% de todo o runner da fatia) |
  | **Spec inteira** | **~206 min** |
  Duas conferências mudam a ordem de grandeza:
  - `gh api repos/<owner>/<repo> --jq .private` → **`true`**. Minutos em repositório privado **são cobrados**; em público, não.
  - `runs-on: windows-latest` → **multiplicador 2×** (Linux 1×, macOS 10×).
  Os ~206 minutos viram da ordem de **~412 minutos faturáveis** — só nesta spec, só na parcela desperdiçada.
- **O que mudou**
  - **`agents/sre.md`**, área "CI": ao quantificar desperdício de CI ou propor mudança de cadência, medir e reportar os três fatores — privado × público, multiplicador do runner lido do `runs-on`, e o total em minutos faturáveis **junto** do total em relógio.
  - **`docs/QUALITY-GATES.md`**, "SRE / CI-CD / Infra": item de checklist. Hoje o checklist fala de cadência e de short-circuit, nunca de custo.
  A distinção público/privado não é detalhe: em repositório público a recomendação passa a ser explicitamente de **latência**, não de custo. Sem ela o agente produz o mesmo argumento urgente nos dois casos, e só um é sobre dinheiro.
- **Nota que a issue faz questão de registrar, e eu subscrevo**
  A recomendação que o `sre` vinha defendendo (comparar `HEAD` com o último SHA aprovado via `gh api`, com 4 modos de falha novos dentro do caminho crítico do check obrigatório) **perdeu** para a solução que o usuário implementou: rodar a suíte quando o PR não é draft — sem mecanismo novo, reaproveitando um estado que o pipeline já mantém, 23 s contra ~13 min por push de artefato.
  O agente estava propondo a alternativa pior enquanto a melhor já existia no próprio manual dele (#300). Isso é sobre o `sre` medir o eixo certo **antes** de defender um desenho, que é exatamente o que esta issue corrige.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter intacto. Versão: `1.31.1` → `1.31.2` (patch).
  Closes #311

(PR #318)

## 1.31.1 — 2026-09-26

- **Por quê**
  `docs/TESTING.md` define o critério de frescor do artefato de cobertura como **o último commit que tocou `src/`/`frontend/`** — nunca o HEAD literal, que avança a cada commit de documentação das etapas de revisão. O template pedia outra coisa: *"sha completo do HEAD no momento da execução"*.
  O campo é a **única peça de máquina** de todo o mecanismo de reaproveitamento. Com ele errado, a regra escrita em `TESTING.md` não tem como ser aplicada por ninguém, por melhor que esteja redigida.
- **O custo medido**
  Fatia F-2 da spec `0005` (observação **O-4** do `qa-engineer`): o dev gravou `f20fa12` no campo e o rotulou como *"último commit de código/teste da fatia"*. `f20fa12` é **docs-only**; o último que toca código é `929e0d0`.
  > O artefato **não está desatualizado** (a medição é posterior a todo o código, e eu a reproduzi número a número nesta rodada), só o rótulo está impreciso — e a imprecisão custa: quem comparar literalmente vai concluir "desatualizado" e **reexecutar 6 minutos de suíte à toa**.
- **O que mudou**
  - **`specs/_template/coverage-summary.template.md`** (as duas cópias): o campo passa a trazer o **comando** — `git log -1 --format=%H -- src/ frontend/` — em vez da descrição em prosa, que era ambígua o bastante para alguém preencher de boa-fé com o HEAD. E a condição de reaproveitamento diz explicitamente "nunca o HEAD literal", com o motivo.
  - **`agents/backend-developer.md`** e **`frontend-developer.md`**: de onde o valor vem, e o que acontece se for `git rev-parse HEAD`.
- **Uma simplificação que caiu de brinde**
  A exceção *"se o commit adicional é só documentação, não rode a suíte — só atualize o campo `Commit` para o SHA final"* **era exatamente o que produzia o valor errado**.
  Com o campo definido como o último commit que tocou código, ele não se move num commit docs-only. A exceção vira "não precisa tocar no artefato" — mais simples, e correta.
- **Alcance**
  Chega a projeto **existente** por causa da #301 (templates resolvidos da instalação, mergeada há minutos). Antes dela, esta correção só valeria para projeto novo — que é precisamente a crítica que a #301 documenta.
- **Verificação**
  `python scripts/check-plugin-sync.py`: nenhuma deriva nova; frontmatter conferido intacto. Versão: `1.31.0` → `1.31.1` (patch).
  Closes #302

(PR #317)

## 1.31.0 — 2026-09-26

- **Por quê**
  Os **docs de governança** já se mantêm atualizados sozinhos: cada skill tem a seção "Onde ficam os docs de governança citados nesta skill", que manda resolvê-los a partir da instalação — e o `CHANGELOG.md` registra que `/sdd-sync-docs` foi descontinuado justamente por isso.
  Os **templates** ficaram de fora dessa consolidação. As 8 skills que os citam apontam para `specs/_template/<nome>.template.md` **relativo ao projeto**, que é a cópia congelada no dia em que ele nasceu. Resultado: toda melhoria de template aprovada aqui só beneficia projetos **novos** — o inverso do desejado, já que projeto maduro é o que mais roda fatia.
- **Custou caro duas vezes, na mesma spec**
  | Template | O que o plugin ganhou | O que aconteceu no projeto |
  |---|---|---|
  | `timing-log.template.md` (#283) | seção "Trabalho conduzido pelo orquestrador" | **reinventada à mão, em prosa, na fatia seguinte à que a criou** — três notas no `timing-log.md`, todas terminando com *"o template deste log não tem lugar próprio para tempo de orquestrador"* |
  | `trd.template.md` (#285) | coluna "`!` no título do PR" | não existia no TRD do projeto, então a quebra de contrato teve de ser pega pelo `sre` **no ato do merge** — exatamente o cenário que a coluna existe para eliminar |
- **O que mudou**
  As 8 skills que citam template (`prd`, `trd`, `implement`, `code-review`, `qa`, `security`, `sre`, `ux-review`) ganham um bloco na **mesma seção** onde já resolvem os docs:
  - Resolver `<nome>.template.md` a partir da **instalação da skill** — no pacote, `skills/create-project/scaffold/specs/_template/`; via junction, `specs/_template/` na raiz do repositório do pipeline. A frase nomeia os dois canais, então é idêntica nas duas cópias e não cria adaptação nova a manter.
  - A cópia do projeto vira **override deliberado**: usada só quando existir **e** divergir por decisão registrada em `docs/PROJECT-CONVENTIONS.md`.
  - Cobre também o caso **"template novo"**, não só "template mudado": projeto criado antes da etapa 4b não tem `ux-review.template.md`, e isso deixa de ser lacuna a reportar.
- **Sobre o caminho escolhido**
  A alternativa que a issue oferecia (um passo de sincronização comparando as duas árvores) reintroduziria o mecanismo manual que o `CHANGELOG.md` descontinuou de propósito — e é a mesma classe de defesa que já falhou na #281 (instrução escrita sem verificação). Confirmado com o usuário antes de aplicar.
- **Uma coisa que deixei de fora**
  `/create-project` continua copiando `specs/_template/` para o projeto novo. Não é nocivo com esta mudança — uma cópia idêntica não "diverge por decisão registrada", então nunca é usada como override —, mas é uma cópia que começa a decair no dia 1. Parar de copiá-la é uma mudança de scaffold com efeito em quem já espera o diretório, e a issue não pediu. Fica como consideração separada.
- **Verificação**
  `python scripts/check-plugin-sync.py`: **nenhuma deriva nova**; bloco presente em 8/8 skills nas duas cópias; frontmatter conferido intacto (a corrupção que descrevi no PR #315 não se repetiu — o script de reflow já foi corrigido).
  Versão do plugin: `1.30.1` → **`1.31.0`** (minor — muda como os templates são resolvidos, não é ajuste de redação).
  Closes #301

(PR #316)

## 1.30.1 — 2026-09-26

- **Por quê**
  A cadência `ci-antes-do-merge` entrou **ontem** (#300, v1.30.0) e foi adotada num projeto real no mesmo dia. Ela funciona exatamente como prescrito — e produziu um efeito colateral que nenhum arquivo do plugin cobria.
  `conclusion: success` passou a ter **dois significados indistinguíveis** pela API de alto nível:
  | Run | Commit | `conclusion` | Duração | Passos caros |
  |---|---|---|---|---|
  | `36268468402` | HEAD, em draft | **`success`** | **23 s** | **15 `skipped`** |
  | `36265416098` | anterior | `success` | 13 m 31 s | executados: 316/316, 219/219, 97,6%/94,0% |
  `gh pr checks`, o ícone verde da UI e `statusCheckRollup` mostram a mesma coisa nos dois casos. Um leitor seguindo a instrução ao pé da letra concluiria *"o CI está verde no HEAD, o código está validado"* a partir de um run **que não compilou o projeto**. O `sre` daquela fatia só não errou porque estranhou a duração de 23 s e foi inspecionar os passos por conta própria.
  A #300 documentou a cadência apenas do lado de **quem desenha o `ci.yml`**. Nada foi dito do lado de **quem lê o resultado** — e são cinco agentes lendo, todos com a mesma instrução que não distingue os dois casos.
- **O que mudou**
  | Arquivo | Mudança |
  |---|---|
  | `agents/{code-reviewer,qa-engineer,security-engineer,sre,ux-designer}.md` | no mesmo ponto em que já pedem `statusCheckRollup`: o verde não prova que a suíte rodou. Inspecionar os passos do run antes de afirmar que o CI cobre o código; se estiverem `skipped`, apontar **qual** run executou a suíte e provar que o código não mudou (`git diff --stat <sha> HEAD -- src tests`) |
  | `docs/GIT-WORKFLOW.md`, "Aguardando CI antes do merge" | a mesma regra no texto que os cinco citam |
  | `docs/QUALITY-GATES.md`, "SRE / CI-CD / Infra" | item de checklist |
  | `agents/sre.md`, receita do gate condicional | o caminho pulado precisa de **passo informativo próprio** — é o que torna o run legível para quem audita depois |
  | `skills/sre/SKILL.md`, passo 5d | sob a cadência, `gh pr ready` deixa de ser cosmético: dispara a **única execução completa da fatia**. Nomeia de quem é a espera (orquestrador, por coerência com a #269) |
  O passo 5d era a segunda metade do problema: como ele não dizia isso, o `sre` daquela fatia divergiu conscientemente da convenção e **não** executou `gh pr ready`, porque o passo não resolvia a ambiguidade.
- **Um erro meu nesta rodada, e como foi corrigido**
  O script que uso para re-quebrar parágrafos **achatou o frontmatter YAML de 12 arquivos** — juntou `name:` e `description:` numa linha só, o que quebra o registro do agente/skill (deu para ver ao vivo: a descrição do `sdd-sre` apareceu truncada no registro de skills da sessão).
  Restaurei o frontmatter do `HEAD` e conferi byte a byte que os 12 voltaram idênticos, que o diff não toca nenhuma linha de frontmatter, e que o conteúdo da #309 sobreviveu. O script passou a preservar frontmatter, para não repetir nas 12 issues restantes deste lote.
- **Verificação**
  `python scripts/check-plugin-sync.py`: **nenhuma deriva nova**. Versão do plugin: `1.30.0` → `1.30.1` (patch).
  Closes #309

(PR #315)

## 1.30.0 — 2026-09-26

- **Por quê**
  O consumo que motivou isto são **minutos de runner do GitHub Actions** — e o pipeline é estruturalmente caro nesse eixo: cada etapa de revisão commita e envia seu artefato na branch da fatia, e **cada push dispara o CI completo**. Uma fatia típica acumula ~10 runs; com os **~11–15 min por run** medidos em runner Windows na #284, são **~2h de runner por fatia**, multiplicado pelo número de fatias da spec.
  A #284 atacou o problema por outro eixo (não repetir a suíte sobre código já testado, comparando com o último run verde). O que faltava era poder **não rodar a suíte completa durante a fatia inteira** — rodá-la uma vez, antes do merge.
- **O encaixe: o PR já fica draft durante toda a fatia**
  Nenhum mecanismo novo foi inventado, porque o pipeline já gerencia o estado exato:
  - `docs/GIT-WORKFLOW.md`, regra 4 — o PR é aberto **em draft no primeiro commit**.
  - `skills/sre/SKILL.md`, passo 5d — o PR **sai do draft (`gh pr ready`) ao final do SRE**, quando a fatia é aprovada, imediatamente antes do merge.
  Então **"CI só antes do merge" é literalmente "CI só quando o PR não é draft"**, e a transição draft → ready é o sinal, produzido pelo próprio fluxo, no momento exato.
- **O que mudou**
  | Arquivo | Mudança |
  |---|---|
  | `agents/sre.md`, área "CI" | a cadência `ci-antes-do-merge` como **opt-in** registrado em `docs/PROJECT-CONVENTIONS.md`, com o esboço de `ci.yml`, a armadilha do *required check*, e o trade-off nomeado |
  | `docs/QUALITY-GATES.md`, "SRE / CI-CD / Infra" | item de checklist correspondente |
  | `agents/codebase-archaeologist.md` | "Cadência de CI" entra nas seções mínimas de `docs/PROJECT-CONVENTIONS.md`, para o arqueólogo saber capturá-la |
  A configuração vive em `docs/PROJECT-CONVENTIONS.md` — canal que já existe e que **todos os 8 agentes passaram a ler na #287**. Zero mecanismo novo de configuração.
- **A armadilha evitada (mesma lição da #284)**
  O gate vai nos **passos caros**, nunca no job nem no gatilho. Um job que não roda não reporta status, e um *required status check* que nunca reporta **bloqueia o PR para sempre** — exatamente a classe de erro que a #284 documentou sobre `paths-ignore`. O job sempre inicia, decide numa linha se deve rodar, e sai: **~1 min de runner em vez de ~13**.
  ```yaml
  jobs:
  test:
  steps:
  - id: cadencia
  shell: bash
  run: |
  if [ "${{ github.event_name }}" = "push" ] || \
  [ "${{ github.event.pull_request.draft }}" = "false" ]; then
  echo "rodar=true" >> "$GITHUB_OUTPUT"
  else
  echo "rodar=false" >> "$GITHUB_OUTPUT"
  fi
  - if: steps.cadencia.outputs.rodar == 'true'
  uses: actions/checkout@v4
  # ... setup, lint, testes, cobertura, build — todos com o mesmo if
  ```
  Compõe com o short-circuit de docs-only da #284 em vez de substituí-lo: quando o PR sai do draft, aquele ainda evita repetir a suíte se o código não mudou desde o último run verde. `workflow_dispatch` entra como escape para forçar um run no meio da fatia.
- **O padrão não muda**
  Arquivo ausente ou sem essa seção = **suíte completa a cada push**, como hoje. A prescrição diz explicitamente que o `sre` **nunca adota a cadência por conta própria** — e nomeia o trade-off real, em vez de vendê-la como ganho puro: o sinal de teste não desaparece durante a fatia (os agentes de implementação rodam a suíte completa com cobertura ao final de cada trilha e registram em `specs/<slug>/coverage/`; o `qa-engineer` reaproveita ou reexecuta — `docs/TESTING.md`), mas **um defeito que só o ambiente do CI pega** (dependência de plataforma, runner Windows, serviço de container) passa a aparecer mais tarde, já com as revisões aprovadas.
- **Verificação**
  `python scripts/check-plugin-sync.py`: **nenhuma deriva nova** — as duas cópias em dia. Fences do bloco YAML balanceados.
  Versão do plugin: `1.29.2` → **`1.30.0`** (minor — capacidade nova opt-in, não ajuste de redação).
  Closes #300

(PR #304)

## 1.29.2 — 2026-09-25

- **Por quê**
  `scripts/check-plugin-sync.py` nasceu (#281) com **33 dos 44 pares idênticos** após normalização e **11 na baseline**, pendentes de ressincronização. Este PR zera a baseline.
  A causa de **8 dos 11** era a mesma, e a issue já suspeitava dela: a instrução de replicação pedia para trocar a referência de caminho de agente *"pela referência genérica ao nome do agente"* — o que é uma **reescrita de frase**, e reescrita produz variantes. Acumularam-se pelo menos seis redações para a mesma referência:
  `siga o mesmo processo descrito no agente \`x\`` · `siga o processo descrito no agente \`x\`` · `do agente \`x\`` · `nos agentes \`a\`/\`b\`` · `da skill \`x\`` · `na skill \`x\``
  Cada variante exige sua própria regra de normalização — e uma regra que engole a prosa em volta do nome **não distingue reescrita de conteúdo perdido de verdade**, que é exatamente a deriva que o script existe para pegar. Tentei o caminho de acrescentar regras primeiro; ele quebrou pares que estavam limpos e não convergiu.
- **O que mudou**
  **1. Convenção fixada** (`plugins/btt-sdd/README.md`, item 3): referência cruzada troca **só o caminho, nunca a frase em volta** — `.claude/agents/<n>.md` → `agents/<n>.md` e `.claude/skills/sdd-<n>/SKILL.md` → `skills/<n>/SKILL.md`, com preposição, passo/seção citado e resto da frase **idênticos à raiz**. São caminhos que de fato existem dentro do pacote do plugin, e os docs bundled já os usavam nessa forma.
  **2. As 25 referências divergentes padronizadas** nas 19 cópias afetadas, mais o conteúdo que tinha se perdido de verdade:
  | Arquivo | O que faltava |
  |---|---|
  | `agents/code-reviewer.md` | a referência a `TESTING.md`, seção "Reaproveitamento do artefato de cobertura entre etapas" (passo 8) |
  | `agents/ux-designer.md` | o "passo 8" da referência cruzada ao `code-reviewer` |
  | `skills/create-project/SKILL.md` | a seção inteira "Onde ficam os docs de governança citados nesta skill" — era a **única** skill do plugin sem ela |
  | `skills/implement/SKILL.md` | "precisar" no lugar de "precisa" (divergência de texto puro) |
  | `skills/project-conventions/SKILL.md` | "adotar o plugin" no lugar de "adotar o pipeline" — o que se adota num projeto é o pipeline |
  **3. Duas divergências genuínas passam a estar em `DELIBERADAS`**, com o motivo escrito: `create-project` (a resolução do caminho do scaffold depende do canal — raiz do repositório × pasta irmã do `SKILL.md` instalado) e `hotfix` (referencia `specs/_template/oneshot.template.md`, que existe só neste repositório).
  **4. Regras de normalização: 8 → 2.** Com as variantes eliminadas, sobrou uma regra por tipo, casando só o caminho. O comentário no script registra a lição: variante nova se resolve **padronizando o texto**, não acrescentando regra.
  **5. `scripts/plugin-sync-baseline.txt` fica vazia de entradas**, com o mecanismo documentado para a próxima deriva que não der para corrigir no mesmo PR.
- **Verificação**
  ```
  $ python scripts/check-plugin-sync.py
  Pares comparados: 44
  ignorado por divergência deliberada: docs/FILE-GUIDE.md (...)
  ignorado por divergência deliberada: .claude/skills/repo-issues/SKILL.md (...)
  ignorado por divergência deliberada: specs/_template/oneshot.template.md (...)
  As duas cópias estão em dia.
  $ echo $?
  0
  ```
  Sobre o tamanho do diff: parte dele é **reflow dos parágrafos editados**, sem mudança de palavra. Cada substituição re-quebra da linha do trecho até o fim do parágrafo — o menor intervalo que não deixa linha órfã curta no meio do texto. O conteúdo de cada arquivo foi comparado com a raiz ignorando quebra de linha, e o script de aplicação falha se perder texto.
  Versão do plugin: `1.29.1` → `1.29.2` (patch — ressincronização e padronização de redação, nenhuma capacidade nova).
  Closes #290

(PR #299)

## 1.29.1 — 2026-09-25

- **Por quê**
  O `architect` já tinha o passo **1b**, que cobre um caso vizinho e mais estreito: premissa **comportamental** de automação de navegador validada só manualmente ("login não é exigido, testei abrindo a URL"). Não havia nada sobre a **forma concreta do contrato** com um sistema externo — seletor de DOM de terceiro, formato de resposta de API não documentada, layout de arquivo/CSV de parceiro, esquema de webhook, nome de campo de um SSO.
  **Por que isso precisa de uma tarefa agendada e não de uma anotação:** nenhuma etapa de revisão do pipeline pega esse erro, por construção. O dublê escrito a partir da suposição **valida a suposição** — a suíte fica verde contra ela, e code review, UX, QA, segurança e SRE revisam o código contra o TRD, que aqui é a fonte do erro. O modo de falha é silencioso de ponta a ponta, e a descoberta vem só na validação pós-merge contra produção, depois de um ciclo completo de pipeline.
- **O caso que justifica**
  Um TRD desenhou a localização de uma linha num modal como:
  ```csharp
  GetByRole(AriaRole.Button, new() { Name = desiredStore, Exact = true })
  ```
  O nome acessível real do botão era, literalmente, `undefined. Dimas (Blumenau).` — com prefixo `undefined. ` e ponto final, em **todas as 17 linhas observadas**, por um defeito do próprio site de terceiro. **O locator desenhado casava zero elementos.** A mesma investigação derrubou outras três suposições do desenho (o nome acessível do gatilho também não casava por texto exato; a busca por rótulo na página inteira retornava 2 ocorrências, exigindo escopo obrigatório ao modal; e o contêiner do modal ficava visível **antes** de as linhas existirem).
  Sem a tarefa de investigação agendada como primeira da primeira fatia, a fatia inteira teria sido implementada contra um locator que não casa nada. É a **terceira spec seguida** do mesmo projeto em que essa tarefa se paga.
- **O que mudou**
  - **`agents/architect.md`, passo 1c** (novo, ao lado do 1b, com a distinção entre os dois explícita): **duas** obrigações, não uma — marcar o contrato como **provisório no próprio texto onde ele aparece** (não numa pendência distante, que quem implementa não lê) **e** criar uma **tarefa de investigação** com Issue GitHub própria, posicionada como **primeira tarefa da primeira fatia** que depende da estrutura. Nomeia explicitamente a armadilha do dublê que valida a suposição.
  - **`agents/architect.md`, decomposição de tarefas**: reforça que essa tarefa entra na tabela como qualquer outra, com dependência declarada — não como nota de rodapé.
  - **`docs/QUALITY-GATES.md`, seção TRD**: gate correspondente, com o motivo (por que nenhuma etapa posterior supre a lacuna).
  - **`specs/_template/trd.template.md`**: a convenção na própria seção 13, com o entregável esperado (snapshot ARIA/DOM, payload real ou amostra do arquivo, mais uma seção "correções obrigatórias ao desenho do TRD") e a emenda do TRD **antes** de a fatia prosseguir.
  Distinta da **#240** (premissa comportamental validada manualmente × automação) e da **#268** (`architect` marcar afirmação sobre biblioteca de terceiro como medida ou não medida): aqui o objeto é a **forma concreta do contrato de integração**, e o remédio pedido é uma tarefa agendada, não uma anotação.
- **Verificação**
  Replicado nas duas cópias (agente, doc, template). `python scripts/check-plugin-sync.py`: **nenhuma deriva nova**. Versão do plugin: `1.29.0` → `1.29.1` (patch).
  Closes #288

(PR #298)

## 1.29.0 — 2026-09-25

- **Por quê**
  O plugin já tinha o arquivo certo para preferência de processo de um projeto — `docs/PROJECT-CONVENTIONS.md`, descrito como *"particularidades deste projeto em relação ao padrão genérico do pipeline"* — mas **nenhum agente o lia**: `grep -rn "PROJECT-CONVENTIONS" plugins/btt-sdd/agents/` casava só dentro do `codebase-archaeologist`, o agente que **escreve** o arquivo. Um arquivo que ninguém lê não é canal.
  Consequência observada numa fatia real: quando o usuário determinou uma **regra de processo permanente** no meio da execução ("teste de mutação não é etapa de fatia — roda no máximo uma vez ao final da spec, e só se ele pedir"), o orquestrador teve que repassá-la manualmente no prompt de **quatro** agentes seguidos (implementação, code review, QA, segurança), e cada um a transcreveu no relatório como *"instrução explícita do usuário nesta rodada"* — a marca de algo que chegou por prompt e não por documento. Tokens duplicados em cada prompt, e nenhuma garantia de que a fatia F-2 ou a próxima spec receberiam o mesmo repasse.
  Compare com `docs/LESSONS-LEARNED.md`, que **é** lido por instrução explícita em vários agentes e funciona exatamente como este canal deveria funcionar: o mecanismo já existia e estava provado, só não tinha sido aplicado aqui.
- **O que mudou**
  - **Os 8 agentes consumidores** (`architect`, `backend-developer`, `frontend-developer`, `code-reviewer`, `qa-engineer`, `security-engineer`, `sre`, `ux-designer`) ganham um bloco de **leitura obrigatória**, posicionado no mesmo lugar onde a resolução dos docs de governança já é explicada: ler o arquivo se existir, tratar cada entrada relevante à etapa como **restrição que se sobrepõe ao padrão genérico**, e registrar no artefato "fora do escopo por `docs/PROJECT-CONVENTIONS.md`" em vez de "por instrução do usuário nesta rodada" — a diferença entre uma regra auditável e um boato repassado. Com dois limites explícitos: **ausência do arquivo é normal** (significa que o projeto segue o padrão), e **uma convenção de projeto não desliga um gate crítico** de `QUALITY-GATES.md` (nesse caso, perguntar em vez de aplicar).
  - **`docs/QUALITY-GATES.md`, "Governança de decisão"**: a regra recíproca, do orquestrador — instrução de processo **permanente** (distinta da decisão pontual sobre esta fatia, que vive no artefato da etapa) vai para `docs/PROJECT-CONVENTIONS.md` na mesma hora, criando o arquivo se não existir, em vez de ser repetida no prompt de cada agente seguinte. Com o critério para distinguir as duas e o caso medido dos quatro repasses.
  - **`agents/codebase-archaeologist.md`**: agora sabe que escreve para consumidores. Cada entrada precisa ser acionável por um agente que **não participou da conversa** em que a convenção foi decidida — com exemplo de entrada vaga ("o time prefere um processo mais leve") versus concreta ("teste de mutação não roda por fatia — no máximo uma vez ao final da spec, e só quando pedido").
  Relacionada a #221, que pediu só a **geração** do arquivo. O que faltava era fechar o circuito.
- **Verificação**
  Replicado nas duas cópias (9 agentes + `QUALITY-GATES.md`). `python scripts/check-plugin-sync.py`: **nenhuma deriva nova**.
  Versão do plugin: `1.28.1` → **`1.29.0`** (minor — um canal novo de configuração de projeto passa a existir de fato, não é ajuste de redação).
  Closes #287

(PR #297)

## 1.28.1 — 2026-09-25

- **Por quê**
  `skills/sre` (passo 4b) e `skills/implement` (passo 5b) já mandavam o **orquestrador** recolher a pergunta que um subagente isolado não conseguiu fazer. `code-review`, `qa`, `security` e `ux-review` não tinham nada equivalente — `grep -n "texto puro\|AskUserQuestion"` nesses quatro arquivos retornava **zero**. O agente registrava a pergunta como VALIDAR DEPOIS no próprio relatório e o orquestrador seguia para a etapa seguinte: a pergunta virava **dívida em vez de resposta**.
  Medido numa fatia real:
  - `security-review.md`, nota de processo no topo: *"esta invocação não tem `AskUserQuestion` disponível (subagente isolado) — **quinta ocorrência no projeto**"*, com duas pendências, uma delas uma pergunta de política que **o usuário responderia em 30 segundos**.
  - `qa-report.md`: uma pergunta binária de comportamento ("a planilha inválida deve ser rejeitada antes de abrir o Chrome?") cuja resposta **muda o veredito** de uma observação.
  Nenhuma é bloqueante — e é exatamente por isso que escapam: ficam em `/sdd-pending` esperando alguém reler o relatório, quando o usuário estava ali, disponível, no turno em que a etapa rodou.
- **O que mudou**
  A issue oferecia duas formas (passo por skill, ou regra genérica nos quality gates). São complementares, então foram aplicadas as duas:
  - **Passo novo em cada uma das quatro skills** — `3c` em `code-review`/`qa`/`security`, `4c` em `ux-review` —, posicionado **antes** de informar o resultado da etapa: apresentar as perguntas via `AskUserQuestion` própria, devolver ao relatório as respondidas **como decisão registrada** (`SendMessage` ao agente se ainda endereçável, ou edição direta da tabela de pendências), e deixar como VALIDAR DEPOIS só o que o usuário realmente não souber responder agora. Cada passo cita o artefato e o agente da sua própria etapa (`qa-report.md`/`qa-engineer`, `security-review.md`/`security-engineer`, etc.).
  - **Regra genérica em `docs/QUALITY-GATES.md`, "Governança de decisão"**: a obrigação vale para o orquestrador de **qualquer** etapa, para que uma etapa futura não nasça com o mesmo buraco.
  O ponto que o texto antigo não deixava explícito, e que agora está escrito nos dois lugares: **registrar em vez de perguntar é o fallback correto do agente**, que não tinha a ferramenta — não é o fallback de quem orquestra, que tem.
  Relacionada a #156 e #179 (ambas fechadas), que padronizaram o fallback apenas para `sre` e para os agentes de implementação; as demais etapas de revisão ficaram de fora.
- **Verificação**
  Replicado nas duas cópias (4 skills + `QUALITY-GATES.md`). `python scripts/check-plugin-sync.py`: **nenhuma deriva nova**. Versão do plugin: `1.28.0` → `1.28.1` (patch).
  Closes #286

(PR #296)

## 1.28.0 — 2026-09-25

- **Por quê**
  O pipeline **sabe declarar** uma quebra de contrato — o `architect` a escreve na seção 13 do TRD desde a #109, e funcionou: numa fatia real a quebra estava declarada em **três** artefatos (PRD-5, TRD seção 13, e o README que a própria fatia escreveu). O que faltava era essa declaração chegar ao artefato que **decide a versão publicada**: o título do PR.
  Num squash merge o subject do commit é o título do PR, e é dele que o cálculo automático de versão por Conventional Commits deriva MAJOR/MINOR/PATCH. Sem o `!` antes dos dois-pontos, a fatia que tornava uma coluna obrigatória — **rejeitando toda planilha que o operador já tinha** — publicaria `v1.10.0`, MINOR, com a seção "quebra de compatibilidade" do changelog vazia. Foi pego na **última etapa do pipeline** (SRE), como a única ressalva bloqueante no ato do merge. Para quem só baixa o `.exe` da página de Releases, o número de versão é o único aviso que chega.
  O guard existia — mas só no cabeçalho do `release.yml` de um projeto, procedimental, dependendo de alguém lembrar dele no ato do merge. Do lado do plugin, `grep -rn "BREAKING CHANGE\|semver\|Conventional Commit" plugins/btt-sdd/` retornava **zero**.
- **O que mudou — a informação atravessa quatro etapas em forma acionável**
  | Etapa | Onde | O que passa a acontecer |
  |---|---|---|
  | TRD | `specs/_template/trd.template.md` | nova coluna **"`!` no título do PR"** (sim/não) na tabela de janelas de quebra, com o porquê de ser acionável e não prosa |
  | TRD | `agents/architect.md` | registra qual fatia carrega a quebra nessa coluna — ele é a primeira etapa que sabe disso |
  | Implementação | `agents/backend-developer.md`, `agents/frontend-developer.md` | se o TRD marca a fatia, o PR **nasce** com `!` no título. Um caractere, antes de qualquer revisão |
  | Revisão de código | `agents/code-reviewer.md` (área 12) + `docs/QUALITY-GATES.md` | confere o `!` **três etapas antes do SRE**; e uma quebra encontrada no diff que o TRD **não** declarou é achado por si só |
  | Regra genérica | `docs/GIT-WORKFLOW.md` | nova seção "Quebra de contrato e o título do PR" |
  A seção nova do `GIT-WORKFLOW.md` é o que torna isso genérico: qualquer projeto com release automatizado a partir de Conventional Commits — o default que o pipeline empurra, via lint do título do PR — tem exatamente o mesmo buraco. E diz explicitamente por que a regra não pode morar só no cabeçalho de um workflow de release: um guard procedimental que depende de alguém lembrar no ato do merge falha exatamente quando mais importa.
- **Relação com issues anteriores**
  Relacionada, mas distinta, da **#109** (que fez o TRD *declarar* a janela — e funcionou, a declaração estava lá) e da **#113** (risco de coordenação de deploy). O que faltava era o **elo** entre a declaração e o número de versão publicado.
- **Verificação**
  Replicado nas duas cópias (4 agentes, 2 docs, 1 template). `python scripts/check-plugin-sync.py`: **nenhuma deriva nova**.
  Versão do plugin: `1.27.19` → **`1.28.0`** (minor, não patch — é uma capacidade nova do pipeline: uma coluna nova no template do TRD e uma área nova de revisão de código, não um ajuste de redação).
  Closes #285

(PR #295)

## 1.27.19 — 2026-09-25

- **Por quê**
  O pipeline exige que **cada etapa de revisão commite e envie seu artefato na branch da fatia**. Consequência estrutural, válida em qualquer projeto que use o pipeline: depois que o código para de mudar, a branch ainda recebe **uma dezena de commits de documentação pura**, cada um disparando o CI completo no PR.
  Medido numa fatia real — os 8 últimos commits da branch são 100% documentação, e 4 chegaram a rodar por completo:
  | Commit | Conteúdo | Resultado | Duração |
  |---|---|---|---|
  | `01ac4ad` | 1 linha de `timing-log.md` | verde | ~11 min |
  | `5ce5494` | 1 linha de `trd.md` + 1 de `timing-log.md` | **VERMELHO** | ~15 min |
  | `4391798` | 1 linha de `timing-log.md` | verde | ~11 min |
  | `449106e` | 1 linha de `timing-log.md` | verde | ~14 min |
  **~4 linhas de Markdown compraram ~50 min de runner Windows** — e quatro sorteios independentes na loteria da flakiness. O vermelho saiu num commit de duas linhas de texto que não podia, por construção, ter mudado comportamento; atribuí-lo custou a maior parte de uma seção da revisão de SRE.
- **As duas formas que não funcionam**
  O que o plugin prescrevia (herdado da #146, fechada) é **ativamente errado**, e a alternativa óbvia também falha:
  - **`paths-ignore` no gatilho**: se o workflow não dispara, o GitHub nunca reporta status para um *required status check* — e um PR só de documentação fica **bloqueado para sempre** por um check que nunca roda.
  - **Job sempre dispara + passo interno comparando contra `github.event.pull_request.base.sha`**: a base do diff é o tip de `main`, então num PR de código o diff do PR inteiro **sempre** contém `src/`, e `docs_only` é `false` para todo push subsequente — inclusive os de documentação pura. O short-circuit só funciona em `push` para `main`, ou seja, exatamente onde o custo **não** está.
  Vale notar que o comportamento atual é o **seguro**: pular os testes no último push deixaria o check obrigatório verde para um SHA cujo código nunca foi testado naquele run. Não era descuido — era uma escolha conservadora cuja consequência nunca tinha sido medida.
- **A receita que passa a ser prescrita**
  Pular o build **apenas quando o código em `HEAD` for comprovadamente idêntico ao de um SHA que já passou no CI nesta mesma branch**:
  1. Consultar, via `gh api` com o `GITHUB_TOKEN` já disponível, o run mais recente **bem-sucedido** do workflow de CI para esta branch, e pegar seu `headSha`.
  2. `git diff --name-only <esseSha> HEAD` e verificar se **todo** arquivo do diff casa o filtro de documentação (`specs/`, `docs/`, `*.md` da raiz).
  3. Nada fora do filtro → o check reporta sucesso em segundos.
  4. **Qualquer falha em qualquer etapa** (sem run anterior, SHA inalcançável, API fora) → trata como não-docs-only e roda a suíte.
  É **estritamente mais seguro** que pular por caminho: só pula quando o código **já passou**, em vez de pular sem nunca ter testado aquele conteúdo. Ganho estimado só na fatia medida: 3 das 4 execuções completas evitadas, **incluindo a que ficou vermelha**.
- **Onde mudou**
  - **`.claude/agents/sre.md`**, área "CI": a prescrição antiga sai; entram as duas formas erradas com o porquê de cada uma, a receita em 4 passos, e a instrução de **reportar como achado** um `paths`/`paths-ignore` existente no gatilho de um check obrigatório (hoje o texto induzia o `sre` a recomendar justamente isso).
  - **`docs/QUALITY-GATES.md`**, "SRE / CI-CD / Infra": item de checklist correspondente, mais um item novo sobre reportar a configuração errada quando ela já existe.
  - **`docs/QUALITY-GATES.md`**, exigência de commit+push do artefato de cada etapa: nota explicando que é essa exigência que gera a rajada de commits docs-only — e que a solução **não** é deixar de commitar o artefato, porque o artefato na branch é o que torna a revisão auditável.
  - **`docs/GIT-WORKFLOW.md`**, regra 4: referência ao "filtro de `paths`" atualizada para o novo mecanismo.
  Não é duplicata da #146: aquela pediu o filtro e foi atendida; esta reporta, com a medição que faltava, que a forma pedida não funciona para o caso que mais importa. Adjacente a #147 (agrupar commits num único push), que ataca o mesmo custo por outro eixo e não substitui esta.
- **Verificação**
  Replicado nas duas cópias. `python scripts/check-plugin-sync.py`: **nenhuma deriva nova** (`agents/sre.md` e `docs/QUALITY-GATES.md` não estão na baseline e seguem idênticos após normalização). Versão do plugin: `1.27.18` → `1.27.19` (patch).
  Closes #284

(PR #294)

## 1.27.18 — 2026-09-25

- **Por quê**
  O `timing-log.md` é, por construção, um registro de **invocações de agente** — colunas `Início | Etapa | Agente | Fatia | Duração`, preenchido pelo orquestrador. O que o template não previa é o caso em que **o próprio orquestrador faz o trabalho**, sem agente nenhum.
  Numa spec real isso aconteceu duas vezes, e nas duas foi a atividade de **maior valor** da etapa:
  | Ocorrência | Custo | O que produziu |
  |---|---|---|
  | Etapa de PRD | ~23 min invisíveis (as invocações de agente somaram 13m30s) | duas rodadas de `AskUserQuestion` com 7 decisões de produto + investigação no site real que **reescreveu a motivação da spec** |
  | Tarefa T-1 da fatia F-1 | 14m09s | investigação ao vivo do DOM real, que **derrubou o seletor desenhado no TRD** |
  Na segunda, o orquestrador improvisou uma linha com `Agente = "orquestrador (sem agente)"` para o item não sumir da retrospectiva — uma convenção inventada na hora, porque o template não a oferecia.
  Não é duplicata da #264: aquela tratou de **wall-clock × tempo de trabalho** dentro de uma linha que já existe (espera de aprovação humana). Aqui o problema é o oposto — trabalho que existiu, custou tempo e produziu o achado central, e para o qual **não havia linha nenhuma** nem valor legal para a coluna `Agente`.
- **O que mudou**
  - **`specs/_template/timing-log.template.md`** (e a cópia do scaffold): nova seção **"Trabalho conduzido pelo orquestrador (sem agente)"** — declara `orquestrador (sem agente)` como valor **legítimo** da coluna `Agente`, lista os três casos em que registrar (investigação executada sem agente; rodadas de `AskUserQuestion` que custaram relógio, distintas da espera passiva por aprovação da seção anterior; intermediação de plano/pergunta de subagente isolado), dá uma linha de exemplo, e explica o motivo. O cabeçalho e a linha-modelo da tabela passam a refletir isso.
  - **Skills `prd` (3c), `trd` (3c) e `implement` (5a)**: frase mandando registrar o trabalho próprio do orquestrador como linha própria, no mesmo passo que já manda registrar a duração.
  - **Skill `sre` (5c, retrospectiva)**: como **ler** essas linhas — contam como qualquer outra; e se uma etapa tem só linhas de agente mas os artefatos da rodada mostram que houve trabalho de orquestrador nela, a série está subestimando aquela etapa, e a análise diz isso em vez de concluir que a etapa foi barata.
  O motivo escrito no template é o que amarra tudo: a retrospectiva de fatia lê esse arquivo para achar etapas anormalmente lentas — e hoje ela lê uma série que **subestima** sistematicamente as etapas conduzidas pelo orquestrador e **superestima** as conduzidas por agente.
- **Verificação**
  Replicado nas duas cópias (template do scaffold + 4 skills). `python scripts/check-plugin-sync.py`: **nenhuma deriva nova** — `timing-log.template.md`, `skills/prd`, `skills/trd` e `skills/sre` não estão na baseline e seguem idênticos após normalização.
  Versão do plugin: `1.27.17` → `1.27.18` (patch).
  Closes #283

(PR #293)

## 1.27.17 — 2026-09-25

- **Por quê**
  O passo 3 de `/sdd-implement` afirmava, para trilha única, que *"o agente segue seu próprio processo em duas fases (plano aprovado via `AskUserQuestion` antes de codar) — **você não precisa orquestrar isso manualmente**"*. Essa frase só vale para invocação síncrona no mesmo contexto. Em invocação isolada/assíncrona (`isolation: "worktree"` ou equivalente), `AskUserQuestion` **não está disponível**: o `backend-developer` faz o certo — devolve o plano da Fase 1 em texto puro e para sem tocar código — e fica parado até o orquestrador intermediar.
  Custo medido na fatia que originou a issue: **6h30m de wall-clock para ~2h de execução efetiva**. As ~4h30m restantes são a parada, contabilizadas no `timing-log.md` que a própria retrospectiva lê. **2ª ocorrência** do mesmo mecanismo — a #179 descreveu as duas saídas possíveis e só a que conserta a *governança* foi implementada; a que elimina a *parada* ficou de fora para trilha única.
- **O que mudou**
  O mecanismo que resolve já existia e já estava escrito — os sub-passos **4a–4d**, usados até aqui só para full-stack. Nada de mecanismo novo: eles passam a ser o caminho padrão para qualquer número de trilhas.
  | Ponto | Antes | Depois |
  |---|---|---|
  | Passo 3 | invocava o agente direto em trilha única, com a frase falsa | identifica as trilhas e manda seguir o passo 4 nos dois casos, com o porquê e o custo medido |
  | Passo 4 (cabeçalho, 4a, 4b, 4c) | só full-stack, "plano combinado" | uma trilha ou duas; "combinado" só quando full-stack |
  | Passo 4d | invoca os dois agentes em paralelo | invoca o(s) agente(s), com a instrução "este plano já foi aprovado pelo orquestrador — pule sua Fase 1" marcada como **não-opcional** |
  | Passo 5b | o caminho documentado para o plano em texto puro | marcado explicitamente como **fallback do desvio**, com a causa apontada (a instrução do 4d não foi passada) |
  | `backend-developer.md` / `frontend-developer.md`, Fase 1 | pula a fase só "como parte de uma feature full-stack com plano aprovado" | pula sempre que houver plano aprovado (trilha única incluída); e se a invocação chegou isolada **sem** plano pré-aprovado, o agente **reporta isso como desvio** junto com o plano |
  A última linha é o que evita a repetição: hoje a parada acontece em silêncio e só aparece no `timing-log.md` depois. Com o agente dizendo "recebi invocação isolada sem plano pré-aprovado", a invocação é corrigida na hora em vez de a parada se repetir na fatia seguinte.
  O passo 3 também registra a única exceção real — agente síncrono no mesmo contexto, com `AskUserQuestion` disponível para ele — em vez de deixar a regra absoluta e imprecisa.
- **Verificação**
  Replicado nas duas cópias (skill + 2 agentes). `python scripts/check-plugin-sync.py` (introduzido em #291): **nenhuma deriva nova** — `backend-developer.md` e `frontend-developer.md` não estão na baseline e continuam idênticos após normalização, o que confirma que a replicação saiu correta nos dois.
  Versão do plugin: `1.27.16` → `1.27.17` (patch).
  Closes #282

(PR #292)

## 1.27.16 — 2026-09-25

- **Por quê**
  O pipeline existe duas vezes — a cópia da raiz (junction de diretório) e `plugins/btt-sdd/` (`claude plugin install`) — e o processo escrito de replicação cobria **só agentes e skills**. `docs/` e `specs/_template/` não apareciam como item a replicar em lugar nenhum, e nada verificava se a replicação aconteceu. Resultado medido na issue: 5 dos últimos 40 commits tocaram `docs/` na raiz sem tocar a cópia do plugin, incluindo a etapa 4b inteira (#280, corrigida em #289). A defesa até hoje era reativa: alguém percebia, ressincronizava um arquivo, e a próxima deriva passava igual.
  A issue oferecia três direções e não tinha preferência. O usuário escolheu **as duas** — instrução para acertar na escrita, verificação para pegar quando não acertar.
- **Instrução escrita**
  - **`plugins/btt-sdd/README.md`**: `docs/*.md` e `specs/_template/*` entram na frase de abertura e ganham os itens 4 e 5 da lista de replicação — com a adaptação legítima de referência a doc (`<DOC>.md do pipeline`, dentro do scaffold) e o motivo pelo qual deriva aqui é pior que doc desatualizada: estes são os arquivos que dizem aos agentes **o que é obrigatório**, então a deriva desliga gates.
  - **`docs/GIT-WORKFLOW.md` (as duas cópias)**: novo passo 3 no checklist de "Mudanças no próprio pipeline" — replicar no mesmo commit e rodar o script, com a explicação de por que a deriva é invisível de dentro da sessão (nesta máquina os agentes leem a cópia da raiz).
  - **`.claude/skills/repo-issues/SKILL.md`**: novo passo `b2`, deixando explícito que deriva nova reprovada é replicação esquecida no passo `b`, não falha do script.
  - **`CLAUDE.md`**: os quatro conjuntos que são cópia, e o script, na seção "Distribuição global".
- **Verificação — `scripts/check-plugin-sync.py`**
  Compara **44 pares** (docs, agentes, skills, templates) normalizando as adaptações legítimas nos **dois** lados para uma forma neutra: namespace de comando (`/sdd-X` ↔ `/btt-sdd:X`), caminho de agente e de skill, referência a doc, `name:` do frontmatter, e o parágrafo "onde os docs de governança vivem" (que difere por canal de distribuição). A comparação ignora quebra de linha — as duas cópias foram escritas à mão e quebram as linhas em pontos diferentes, o que fazia um diff ingênuo reportar 987 linhas divergentes onde havia 22 blocos de conteúdo.
  Três registros, nenhum silencioso:
  | Registro | Para quê |
  |---|---|
  | `REGULARES` | adaptação que aparece em muitos arquivos, colapsada a um token comum |
  | `DELIBERADAS` | divergência específica de um arquivo (`pular`, `cortes`, `trocas`) — cada âncora é conferida **nos dois lados**: âncora ausente falha como "allowlist desatualizada" em vez de deixar de comparar em silêncio |
  | `scripts/plugin-sync-baseline.txt` | deriva que já existia quando o script nasceu |
  **33 dos 44 pares ficam idênticos** após a normalização. Os **11 restantes** estão na baseline, cada um com motivo e a issue que o resolve (**#290**), para o gate valer desde o primeiro dia sem depender de uma ressincronização completa antes. Um par da baseline que voltou a estar em dia **também falha** o script, obrigando a linha a sair — a baseline não pode virar um tapete permanente.
- **Como foi verificado**
  - `python scripts/check-plugin-sync.py` → `Nenhuma deriva nova`, exit `0`.
  - Uma linha inventada acrescentada a `plugins/btt-sdd/docs/QUALITY-GATES.md` → reportada como `Deriva NOVA`, com o bloco divergente citado e exit `1`. Revertida.
  - Rodado também por grupo (`... docs`) para confirmar o filtro.
  Versão do plugin: `1.27.15` → `1.27.16` (patch — `README.md` e `docs/GIT-WORKFLOW.md` do pacote mudaram; o script em si não é distribuído, é manutenção deste repositório, como `/repo-issues`).
  Closes #281

(PR #291)

## 1.27.15 — 2026-09-25

- **Por quê**
  A cópia de `docs/` bundled com o plugin estava defasada em relação a `docs/` da raiz, e a defasagem mais grave era estrutural: **a etapa 4b (UX review) nunca chegou aos docs do plugin** — mesmo com `plugins/btt-sdd/agents/ux-designer.md` e `plugins/btt-sdd/skills/ux-review/SKILL.md` já replicados e atualizados. Para quem instalou o plugin, `/btt-sdd:ux-review` existia mas nenhum doc de governança que os agentes leem mencionava a etapa — um `sre` podia aprovar o merge de uma fatia com UI sem que nada no checklist pedisse a 4b, exatamente o oposto de "registrando a decisão como 'não aplicável' em vez de omiti-la silenciosamente".
- **O que mudou**
  Ressincronizado a partir da raiz, normalizando as adaptações regulares (namespace de comando `/sdd-X` → `/btt-sdd:X`, caminhos `.claude/agents/` → `agents/` e `.claude/skills/sdd-X/` → `skills/X/`):
  | Doc | Antes | Depois | Estado |
  |---|---|---|---|
  | `QUALITY-GATES.md` | 457 | 524 | idêntico à raiz após normalização |
  | `SDD-WORKFLOW.md` | 245 | 277 | só a seção final divergindo (deliberada) |
  | `TESTING.md` | 191 | 225 | só "Comando de referência" e a nota de `ci.yml` (deliberadas) |
  | `ARCHITECTURE.md` | 106 | 110 | só a referência ao exemplo `specs/0001-...` (deliberada) |
  | `FILE-GUIDE.md` | 92 | 93 | divergência de audiência preservada; UX acrescentado |
  Recuperados em `QUALITY-GATES.md`: a seção inteira `## UX / Usabilidade (ux-designer, condicional)`, o item de pré-condição do QA, o item de merge exigindo UX aprovada (ou "não aplicável"), a consulta sobre alteração de UI no checklist de PRD, os dois itens "Na fatia final que fecha o spec" e o item de `sre` documentar a resolução nas issues do GitHub. Menções de UX no plugin: `QUALITY-GATES.md` 0 → 13, `SDD-WORKFLOW.md` 0 → 5 (mesma contagem da raiz).
- **Adaptações legítimas preservadas**
  - `SDD-WORKFLOW.md`: `## Primeira feature deste projeto` no lugar de `## Exemplo completo` (o projeto consumidor não tem `specs/0001-example-task-management/`).
  - `TESTING.md`: `## Comando de referência` na versão "projeto ainda não tem stack definida", e a nota de `ci.yml` "criado pelo `sre` junto com a primeira feature implementada".
  - `ARCHITECTURE.md`: sem a referência ao exemplo documentado deste repositório.
  - `FILE-GUIDE.md`: **não** ressincronizado — a cópia do plugin é escrita para o projeto que instalou o plugin ("os agentes não vivem neste projeto — vêm do plugin"), não para este repositório. Confirmado com o usuário como divergência deliberada. Recebeu só o que faltava de UX: `ux-designer` e `tech-writer` na lista de agentes, a etapa 4b na contagem de etapas condicionais, e `ux-review`/`timing-log` na lista de templates.
- **Verificação**
  O texto de cada doc gerado foi comparado com a raiz normalizada ignorando quebra de linha (hash do conteúdo colapsado): nenhuma perda de conteúdo no reflow. A comparação bloco a bloco final mostra divergência **só** nos pontos deliberados listados acima. `ENGINEERING-PILLARS.md`, `POST-MERGE-VALIDATION.md` e `GIT-WORKFLOW.md` (este ressincronizado no #237) já estavam em dia e não foram tocados.
  Versão do plugin: `1.27.14` → `1.27.15` (patch — a capacidade de UX review já era distribuída; o que faltava era a governança que a torna obrigatória).
  Closes #280

(PR #289)

## 1.27.14 — 2026-09-24

- **Problema**
  O PR #127 da fatia F-1 de `0004-sem-retentativa-cor-indisponivel` (`projeto-B`) tinha no corpo:
  ```
  Closes #117, #118, #119, #120, #121
  ```
  Após o squash-merge, **apenas a #117 foi fechada**. O GitHub só reconhece a palavra-chave aplicada ao número **imediatamente seguinte** — a forma correta repete:
  ```
  Closes #117, Closes #118, Closes #119, Closes #120, Closes #121
  ```
  As outras quatro tiveram de ser fechadas à mão, e só foram notadas porque o orquestrador **conferiu** o estado das issues após o merge em vez de assumir que o `Closes` tinha funcionado. O erro é invisível sem essa conferência: o corpo do PR *parece* correto, e ninguém relê issues fechadas.
  **O impacto não é cosmético.** Issue aberta sem motivo faz a spec parecer ter tarefas pendentes que já estão em produção; `/sdd-status` e `/sdd-pending` reportam trabalho pendente que não existe; e o gate do passo 2c-ter de `/sdd-implement` (toda tarefa precisa de issue associada) pode levar uma fatia futura a **reimplementar** trabalho já mergeado — exatamente o cenário que o passo 2b-ter existe para evitar.
- **O que muda**
  Duas mudanças, uma em cada ponta do ciclo:
  **Forma correta na escrita**
  - `docs/GIT-WORKFLOW.md`, **regra 5b** nova: `Closes` repetido por issue, nunca a lista com vírgulas simples — com o porquê escrito ao lado da regra, senão a forma "mais limpa" volta sozinha.
  - Replicada nas instruções de abertura de PR de **`backend-developer`** e **`frontend-developer`**, e no checklist de Implementação de `docs/QUALITY-GATES.md`.
  **Rede de segurança na leitura**
  - `docs/GIT-WORKFLOW.md`, **regra 5c** nova: depois do merge, confirmar `gh pr view <PR> --json closingIssuesReferences` e fechar à mão as que sobraram.
  - **`/sdd-implement`, passo 2c-quater novo** — junto do ponto onde o merge da fatia anterior já é confirmado, então não é uma ida a mais ao GitHub.
  - **`/sdd-hotfix`, passo 7** — mesma verificação depois do merge.
  - Item correspondente no checklist "Merge para `main`" de `docs/QUALITY-GATES.md`.
  É barato e fecha o buraco mesmo quando o corpo do PR estiver errado — inclusive em PRs antigos.
  Replicado para `plugins/btt-sdd/`; versão do plugin `1.27.13` → `1.27.14`.
  Closes #271

(PR #279)

## 1.27.13 — 2026-09-24

- **O aprendizado**
  **Quando uma feature corrige uma classe de defeito, as correções de achados de revisão das fatias seguintes são o lugar mais provável de reintroduzi-la.** O motivo é estrutural: a atenção de todos está no **achado** (o que foi apontado), não na **classe** (o que a feature existe para impedir); e a correção é pequena, o que desarma a desconfiança.
- **O caso**
  Spec `0004-sem-retentativa-cor-indisponivel` (`projeto-B`). A fatia F-1 existia, em parte, para corrigir um defeito latente com esta forma:
  > uma exceção lançada de **dentro de um caminho de reporte de falha** escapava da linha e, via `Task.WhenAll`, derrubava o **lote inteiro** — em vez de falhar só aquela linha.
  Corrigido, mergeado, revisado por quatro etapas. Na fatia seguinte (F-2), o `code-reviewer` apontou uma ressalva legítima: um braço `_ => SpecificReason` num `switch` faria uma categoria futura renderizar **sem declaração de desfecho**, silenciosamente. O desenvolvedor a fechou com:
  ```csharp
  _ => throw new NotSupportedException(...)
  ```
  **Dentro do mesmo método de renderização de falha** que F-1 acabara de endurecer. A correção de um achado de revisão reintroduziu, numa forma vizinha, exatamente o vetor que a fatia anterior eliminou — e passou pelo desenvolvedor **e** pelo revisor que levantou a ressalva, porque ambos olhavam para "a categoria fica sem declaração?", não para "o que acontece se isto disparar?".
  Três medições mudaram a conversa:
  1. Acrescentar uma **4ª categoria real ao enum e compilar**: 0 avisos, 0 erros — o braço `_` suprime o `CS8509`. A "rede de compilação" que justificaria o `throw` **nunca existiu**; ele a *custava*, não a comprava.
  2. O caminho real era avaliação **ávida** dentro do construtor de resultado, chamado de dentro dos `catch`, sem `catch` externo, com o `Task.WhenAll` acima.
  3. O argumento decisivo: no cenário em que dispara, **o resultado é pior que a violação que ele guarda**. O invariante era "nunca uma falha sem classificação"; o `throw` não produz falha sem classificação — produz **nenhum relatório para nenhuma linha**, inclusive as bem-sucedidas.
  A forma final foi degradação local (declaração genérica) + teste de exaustividade mais apertado.
- **O que muda**
  - **`/sdd-implement`, seção "Retomando para corrigir achados de revisão", passo 3d novo**: se a fatia (ou a spec) existe para eliminar uma classe de defeito, o orquestrador **inclui a verificação no pedido que manda ao agente**, em vez de esperar que ele lembre. Com o sinal de alerta nomeado (a correção acrescentar um `throw`, um `return` de erro, ou qualquer caminho de exceção novo) e a pergunta a fazer: **não** "isto resolve o achado?", e sim **"se isto disparar, o resultado é melhor ou pior que a violação que ele guarda?"**.
  - **`code-reviewer.md`, seção "Escopo de uma rodada de reverificação de achado específico"**: um achado **cuja correção** cria caminho de exceção novo merece reverificação da **classe**, não só a confirmação de que o achado original fechou — com força extra quando o achado foi levantado pelo próprio revisor, que é justamente quando a atenção fica mais presa ao achado.
  Replicado para `plugins/btt-sdd/`; versão do plugin `1.27.12` → `1.27.13`.
  Closes #270

(PR #278)

## 1.27.12 — 2026-09-24

- **Problema**
  `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge", orientava corretamente a esperar o CI antes do merge. Mas **o merge é decisão do usuário, conduzida pelo orquestrador** — e não havia nada dizendo ao agente de revisão que a espera não é dele.
  Medido no `timing-log.md` da fatia F-2 de `0004-sem-retentativa-cor-indisponivel` (`projeto-B`):
  | Etapa | Agente | Duração |
  |---|---|---|
  | Implementação | `backend-developer` | 26m46s |
  | Code review | `code-reviewer` | 24m30s |
  | Correção pontual | `backend-developer` | 51m37s |
  | Reverificação pontual | `code-reviewer` | 15m30s |
  | QA | `qa-engineer` | 15m29s |
  | Segurança | `security-engineer` | 12m34s |
  | **SRE** | `sre` | **6h52m** |
  Quase **8× a segunda maior etapa** — e não por volume de trabalho: a auditoria foi comparável à que o mesmo agente fez em F-1 da mesma spec em **17m13s**. A diferença foi `gh run watch`, acompanhando o run do GitHub Actions até o fim — inclusive os runs que os **próprios commits de documentação do agente** dispararam, num projeto cujo build completo leva ~11 min.
  O prejuízo é duplo: tempo de parede desperdiçado num `watch` sem trabalho nenhum, e um `timing-log.md` enganoso — o mesmo arquivo que a retrospectiva do próprio `sre` lê para identificar etapas anormalmente lentas. O log passou a dizer "SRE é a etapa mais cara desta spec" quando o trabalho de SRE foi um dos mais baratos. Uma análise de performance futura tiraria a conclusão errada a partir desse número.
- **O que muda**
  - **`docs/GIT-WORKFLOW.md`**, seção "Aguardando CI antes do merge", ganha um parágrafo no topo dizendo **de quem é a espera** e o que o agente de revisão faz em vez de esperar: confirma o estado atual dos checks (`gh pr view <PR> --json statusCheckRollup,headRefOid`), reporta no próprio artefato — quais commits estão cobertos por qual run, se o push dele mesmo disparou um run novo, se o último run verde cobre o código atual — e encerra.
  - **`code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer` e `sre`** ganham a instrução explícita, cada um citando o próprio artefato. No `sre` — que mediu o caso e é quem lê o `timing-log.md` na retrospectiva — com os números reais.
  - Duração dominada por espera passa a ser **declarada como tal na própria entrada** do `timing-log.md`, apoiada na seção "O que a coluna 'Duração' mede" criada pela #264: sem isso, o número entra na série histórica como se fosse custo de trabalho.
  O `ux-designer` entra junto por ser etapa de revisão pela mesma regra (etapa 4b), ainda que a issue não o cite — deixá-lo de fora criaria exatamente a divergência entre agentes de revisão que a instrução existe para evitar.
  Replicado para `plugins/btt-sdd/` (5 agentes + doc); versão do plugin `1.27.11` → `1.27.12`.
  Closes #269

(PR #277)

## 1.27.11 — 2026-09-24

- **Problema**
  O TRD da spec `0004-sem-retentativa-cor-indisponivel` (`projeto-B`), seção "Riscos e trade-offs", descrevia um risco assim:
  > **Motivo raspado da página muito longo** pode, em teoria, aproximar o limite de 32.767 caracteres por célula de `.xlsx` (ClosedXML lançaria, virando `PersistFailedException` para aquela linha).
  A revisão de segurança mediu com a biblioteca real (ClosedXML 0.104.1) e constatou que **as duas metades estavam erradas**:
  1. O tipo lançado é `System.ArgumentOutOfRangeException`, que **não** é `IOException` nem `UnauthorizedAccessException` — portanto **escapa** do `catch when` do adapter de persistência;
  2. Não existe contenção por linha nenhuma: `RecordOutcomeAsync` é chamado **fora** do `try` do caso de uso, então qualquer falha de persistência sobe ao `Task.WhenAll` e **derruba o lote inteiro**.
  O impacto real era o oposto do descrito — o TRD apresentava como **contido na linha** um risco que derruba o processamento inteiro do operador, e era o mesmo vetor de negação de serviço acionável por conteúdo de terceiro que aquela fatia estava corrigindo num gatilho vizinho, só que descrito de forma a parecer inofensivo.
  **Por que passou:** a afirmação estava numa tabela de riscos, escrita com hedge ("em teoria", "lançaria"), o que a fazia parecer análise prudente. Atravessou a aprovação do TRD, a implementação e duas etapas de revisão sem ser questionada — afirmações sobre comportamento de biblioteca de terceiro *parecem* factuais e não convidam à verificação.
- **O que muda**
  - **`architect.md`, passo 6f novo**: toda afirmação sobre comportamento concreto de biblioteca de terceiro ou de runtime (tipo de exceção lançada, limite numérico, formato gravado, o que um `catch` captura) vem marcada **`[medido]`** (com a versão da biblioteca e como foi medido) ou **`[não medido]`** (hipótese de leitura de documentação/código, a verificar por quem depender dela). Custo praticamente zero para quem escreve, e transforma uma armadilha silenciosa em item acionável: uma afirmação marcada "não medida" convida a etapa seguinte a medir.
  - **A mesma regra vale para a alegação de contenção** registrada ao lado do risco: dizer que algo "vira falha daquela linha" é uma afirmação sobre o próprio código — **cite o ponto onde a contenção acontece**. Se ninguém conseguir citar o ponto, a contenção provavelmente não existe.
  - **`specs/_template/trd.template.md`, seção 12**: a regra no próprio template, com coluna "Evidência" na tabela de riscos.
  - **`docs/QUALITY-GATES.md`, seção TRD**: item de checklist correspondente, para que o gate seja verificável na aprovação e não só uma instrução do agente.
  Replicado para `plugins/btt-sdd/` (agente, doc e template do scaffold); versão do plugin `1.27.10` → `1.27.11`.
  Closes #268

(PR #276)

## 1.27.10 — 2026-09-24

- **Problema**
  Uma entrada de `docs/LESSONS-LEARNED.md` acumula autoridade junto com ocorrências. Quando ela carrega uma **métrica de ambiente** na assinatura ou na causa, cada nova ocorrência que a repete *parece* confirmá-la quando na verdade só a está copiando — e a conduta que a métrica induz nunca é questionada.
  No projeto `projeto-B`, uma lição de flakiness da suíte de integração chegou à **18ª ocorrência** citando "71 `chrome.exe` + 7 `dotnet.exe` concorrentes de outros worktrees" como causa ambiental, e como razão para esperar/reexecutar. Na fatia F-1 da spec `0004`, o `sre` **mediu em vez de citar** (`Get-CimInstance`), sob exatamente os mesmos números de manchete:
  - dos 71 `chrome.exe`, **só 2 são navegadores** — os outros 69 são processos filhos (59 renderer, 6 utility, 2 gpu, 2 crashpad);
  - **60 dos 71** pertencem ao Chrome **pessoal do operador**, aberto **4 dias antes** da spec começar;
  - **9** são **um** Chrome CDP remanescente da própria aplicação, sobrevivente de uma sessão sem teardown;
  - `testhost.exe` = **0**, e 6 dos 7 `dotnet.exe` são nós **ociosos** de node reuse do MSBuild;
  - máquina com 24 núcleos lógicos e 13,1 GB livres de 47,8 GB.
  Quase toda a "contenção de worktrees concorrentes" era **ambiente estático**, presente e inalterado em todas as medições da spec. A flakiness é real — nada nessa medição desmente os 18 timeouts. O que ela desmonta é a **explicação causal**, e a conduta que essa explicação induzia: "esperar a contenção baixar" nunca converge, porque o número quase não desce — ele não vem de onde a lição supunha. Foi preciso a 18ª ocorrência para alguém medir.
- **O que muda**
  `docs/QUALITY-GATES.md`, seção "Lições aprendidas recorrentes", ganha dois itens:
  1. **Métrica de ambiente vale só para a ocorrência que a mediu** — remedir e reatribuir é parte de registrar a ocorrência nova, não um extra. Para métricas de processo/recurso, medir significa responder as duas perguntas que o número de manchete não responde: quantos dos processos contados são realmente o que se supõe (processo real vs. processo filho), e **desde quando existem**. Repetir sem remedir registra **correlação, não causa**.
  2. **A recíproca**: entrada cuja métrica se mostra mal atribuída tem a **prosa corrigida** ("Padrão observado", "Recomendação para implementação"), não só a contagem incrementada — é o que impede as ocorrências seguintes de herdarem a explicação errada.
  Replicado para `plugins/btt-sdd/docs/`; versão do plugin `1.27.9` → `1.27.10`.
  Closes #267

(PR #275)

## 1.27.9 — 2026-09-24

- **Problema**
  Quando um agente de implementação reporta uma **auto-avaliação quantificada da força dos próprios testes** — tabela de mutações, "mutei X e N testes morreram", contagem de asserções discriminantes — nada instruía a etapa de revisão a tratá-la com desconfiança. É relato do autor sobre o próprio trabalho: aceitá-lo e seguir adiante devolve um gate que *parece* cumprido e não foi.
  Na fatia F-1 de `0004-sem-retentativa-cor-indisponivel` (`projeto-B`) o orquestrador pediu essa desconfiança explicitamente, e três agentes independentes justificaram o pedido:
  | Agente | O que fez | O que encontrou |
  |---|---|---|
  | `code-reviewer` | Reaplicou 4 das 6 mutações **e criou 2 que o autor não tinha feito** (as de normalização) | As 2 novas mataram 1 e 12 testes — um bloco que estava sem mutação nenhuma. A numeração pulava de `M5` para `M7`, e o revisor **não presumiu** erro de numeração: identificou o bloco descoberto e o mutou |
  | `qa-engineer` | Mutação própria sobre o literal de reserva | **Achou o único buraco real**: mover o literal para dentro de uma das fábricas mantinha a suíte **inteira** verde e ressuscitava o defeito latente nos outros dois caminhos |
  | `security-engineer` | 3 mutações próprias | Confirmou que a ordem de composição do texto é o que sustenta a defesa contra injeção de fórmula (inverter a ordem mata 9 testes) |
- **O que muda**
  - **`code-reviewer.md`, área 4** (qualidade dos testes em si): auto-avaliação quantificada é **hipótese a verificar, nunca evidência**. Duas heurísticas concretas — (a) reexecutar um subconjunto das mutações relatadas, escolhendo as de maior consequência; (b) procurar o bloco que a tabela **não** cobre e mutá-lo. Fica dito explicitamente que **uma lacuna na tabela é mais informativa que qualquer linha presente nela**, e que um número faltando na sequência (`M5` → `M7`) é sinal a investigar, não a arredondar.
  - **`qa-engineer.md`, passo 3c novo**: mesma verificação por amostragem, com duas exigências próprias da etapa — registrar no `qa-report.md` quais mutações foram executadas e o que cada uma matou, e, se a correção do buraco vier numa rodada seguinte, exigir que ela **reproduza a medição** (em número e em nome de teste), não só declare o achado fechado. Foi exatamente assim que a correção daquela fatia foi validada: 2 casos novos morrendo, 227 verdes.
  Replicado para `plugins/btt-sdd/agents/`; versão do plugin `1.27.8` → `1.27.9`.
  Closes #266

(PR #274)

## 1.27.8 — 2026-09-24

- **Problema**
  A seção "Retomando para corrigir achados de revisão" já ensina a dosar o **contexto** pela complexidade da correção (passo 1b), mas não tinha equivalente para o **custo de validação**: uma correção de 3 `InlineData` pagava o mesmo preço de validação que uma fatia inteira.
  Medido na fatia F-1 de `0004-sem-retentativa-cor-indisponivel` (`projeto-B`): a rodada de correção foi **a etapa mais longa da fatia** — 41m14s, mais que a implementação inteira (34m45s). O que ela mudou: **3 `InlineData` num arquivo de teste unitário e um comentário de XML doc**. Zero linhas de comportamento.
  O tempo não foi gasto na correção. Foi gasto rodando a suíte de integração completa (158 testes, navegador real) **duas vezes**, ambas vermelhas por flakiness de ambiente — para validar uma mudança que não tocava nenhuma linha de produção. Nos **dois** runs de CI em runner dedicado da mesma fatia, os mesmos 158 testes passaram verdes de primeira, sem rerun.
- **O que muda**
  - **`/sdd-implement`, passo 3a novo** (logo após o passo 3, que mantém a suíte completa como padrão): se o diff da correção **não toca nenhum arquivo de `src/`/`frontend/`**, ou toca apenas código que a suíte rápida cobre integralmente, a validação local pode ser escopada aos módulos afetados — com o **CI do PR verde no commit final** como gate real, e com o relatório declarando explicitamente o que rodou localmente, o que foi delegado ao CI, e por quê. A omissão dessa declaração é o que transformaria escopar num atalho silencioso.
  - A exceção é explicitamente estreita: **correção que toca comportamento de produção continua exigindo a suíte completa local** antes de empurrar para o CI.
  - **`docs/TESTING.md`**, seção "Reaproveitamento do artefato de cobertura entre etapas", diz o mesmo na regra canônica: uma correção que não toca código não move o último commit que tocou código, então a suíte completa já rodou contra exatamente o código que continua lá — o critério de frescor do artefato de cobertura que aquela seção já define.
  A revisão de segurança daquela mesma fatia já fazia exatamente isto (rodou só os 46 testes dos módulos tocados, apoiada no CI verde, declarando o motivo) — era defensável e bem documentado, mas até agora era um desvio da instrução, não um caminho previsto por ela.
  Replicado para `plugins/btt-sdd/`; versão do plugin `1.27.7` → `1.27.8`.
  Closes #265

(PR #273)

## 1.27.7 — 2026-09-24

- **Problema**
  A instrução de registro em `timing-log.md` (`/sdd-implement` passo 5a, e equivalentes nas outras skills) dizia literalmente "o horário anotado no passo 3 ... o horário atual, e a diferença calculada" — wall-clock puro do início ao fim da invocação.
  Quando a invocação inclui uma **pausa para aprovação humana** (o agente devolve o plano da Fase 1 e fica parado até o usuário responder, passo 5b), esse número registra o tempo de resposta do usuário como se fosse custo do pipeline. Na fatia F-3 de `0003-selecao-cor-disponivel-reserva` (`projeto-B`) o gap real foi de mais de 10h: seguida ao pé da letra, a instrução teria produzido a linha `Implementação | backend-developer | F-3 | 10h+`.
  Esse arquivo é lido pela retrospectiva de fatia do `sre` justamente para identificar etapas anormalmente lentas — um número desses leva à conclusão errada. O orquestrador daquela sessão percebeu e registrou a soma das durações reais dos subagentes, com nota explicativa, mas isso foi julgamento improvisado: nenhuma instrução cobria o caso.
- **O que muda**
  - **`specs/_template/timing-log.template.md`** ganha a seção **"O que a coluna 'Duração' mede"**: tempo de trabalho do(s) agente(s) da invocação, somável a partir do `duration_ms` que cada notificação de conclusão de subagente já reporta, com **nota parentética obrigatória** declarando o que ficou de fora — com o exemplo real daquela fatia. O template é o lugar canônico porque é lido por todo orquestrador que escreve no log, não só pelo de `/sdd-implement`.
  - A recíproca fica explícita na mesma seção: **número medido nunca é "limpo"/arredondado**. Se a duração foi de fato dominada por trabalho lento, registra-se o valor medido com a causa na nota — inventar um número arredondado corrompe a série histórica tanto quanto deixar o outlier sem explicação.
  - **`/sdd-implement` passo 5a** aponta para essa regra no caso concreto que a motivou (pausa de aprovação entre Fase 1 e Fase 2).
  Replicado para `plugins/btt-sdd/` (skill `implement` + template do scaffold); versão do plugin `1.27.6` → `1.27.7`.
  Closes #264

(PR #272)

## 1.27.6 — 2026-09-22

- Documenta a heurística de dois sinais (mesmo teste do achado original + diff de código relevante → investigar; teste diferente + sem diff de código → reexecutar antes de escalar) na seção "Aguardando CI antes do merge" de `docs/GIT-WORKFLOW.md`, logo após o parágrafo já existente sobre timeout por concorrência (padrão análogo).
- Replica a mesma edição em `plugins/btt-sdd/docs/GIT-WORKFLOW.md` (cópia sincronizada, ajustando prefixo de comando) e bumpa a versão patch em `plugins/btt-sdd/.claude-plugin/plugin.json` (1.27.5 → 1.27.6).
Closes #262

(PR #263)

## 1.27.5 — 2026-09-21

- **O que mudou**
  - `.claude/agents/backend-developer.md` (+ réplica `plugins/btt-sdd/agents/backend-developer.md`): passo 2 (ciclo TDD red-green-refactor) e passo 5 (suíte completa) reforçam explicitamente rodar comandos de teste em primeiro plano, nunca `run_in_background`.
  - `.claude/agents/frontend-developer.md` (+ réplica `plugins/btt-sdd/agents/frontend-developer.md`): mesmo reforço nos passos 3 e 5.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.27.4` → `1.27.5` (patch).
- **Por quê**
  Closes #260
  `docs/QUALITY-GATES.md` já tinha a regra geral ("Comando de build/teste que o próprio agente precisa aguardar antes de decidir o próximo passo sempre roda em primeiro plano... nunca em background"), mas nenhum dos dois agentes de implementação citava isso no próprio ciclo TDD, onde a situação realmente ocorre. Numa invocação real de `backend-developer` (fatia F-2, `projeto-B` PR #107), um `dotnet test` disparado em background pausou o turno do agente 3 vezes seguidas na mesma trilha, exigindo o orquestrador descobrir o PID, esperar manualmente, e retomar via `SendMessage` a cada vez — sem nenhum ganho de paralelismo real, já que não havia outro trabalho útil para o agente fazer nesse meio-tempo.

(PR #261)

## 1.27.4 — 2026-09-21

- **O que mudou**
  - `.claude/skills/sdd-sre/SKILL.md` (+ réplica `plugins/btt-sdd/skills/sre/SKILL.md`): novo passo **5d** — se a fatia é aprovada (ou aprovada com ressalvas não-bloqueantes), confere `gh pr view <PR> --json isDraft` e roda `gh pr ready <PR>` quando ainda estiver em draft, antes da mensagem final do passo 6. Reprovado não passa por este passo.
  - `docs/GIT-WORKFLOW.md` (+ réplica no plugin): regra 4 e a tabela de mapeamento etapa→ação de Git atualizadas para documentar essa transição automática.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.27.3` → `1.27.4` (patch).
- **Por quê**
  Closes #255
  3ª ocorrência do mesmo padrão em PRs diferentes (#66, #86, #105 do projeto `projeto-B`): o PR nasce em draft (`docs/GIT-WORKFLOW.md`, regra 4), o pipeline inteiro roda e aprova a fatia, mas o PR continua `mergeable=MERGEABLE`/`mergeStateStatus=CLEAN` e mesmo assim bloqueado na UI do GitHub até uma transição manual para "Ready for review" que só o usuário pode fazer — nada no pipeline fazia essa transição sozinho.

(PR #259)

## 1.27.3 — 2026-09-21

- **O que mudou**
  - `docs/GIT-WORKFLOW.md` (+ réplica `plugins/btt-sdd/docs/GIT-WORKFLOW.md`), seção "Isolamento de working tree entre agentes concorrentes": reformula o parágrafo sobre `git checkout <branch-da-fatia>` falhar por colisão de worktree — de "se falhar, faça X" para "isso **vai** falhar a partir da 2ª etapa de revisão sequencial da mesma fatia, vá direto para o workaround em vez de tentar o checkout normal de novo". Implementa a "alternativa mais simples" que a própria issue sugeria (documentar o workaround como caminho normal, não exceção), em vez da alternativa mais complexa (orquestrador remover o worktree da etapa anterior antes de invocar a próxima).
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.27.2` → `1.27.3` (patch).
- **Por quê**
  Closes #254
  O workaround já estava documentado (adicionado depois de uma 3ª ocorrência anterior), mas o enquadramento "se falhar" não impediu uma 4ª ocorrência: na fatia F-1 de `0003-selecao-cor-disponivel-reserva` (`projeto-B`, PR #105), cada uma das três últimas etapas de revisão sequenciais (`code-reviewer`, `qa-engineer`, `security-engineer`) bateu no mesmo erro e precisou redescobrir o mesmo workaround, mesmo com a seção já existindo. A mudança deixa explícito que isso é esperado a partir da 2ª etapa — não vale a pena tentar diagnosticar de novo.

(PR #258)

## 1.27.2 — 2026-09-21

- **O que mudou**
  - `docs/GIT-WORKFLOW.md` (+ réplica `plugins/btt-sdd/docs/GIT-WORKFLOW.md`), seção "Isolamento de working tree entre agentes concorrentes": novo alerta logo após o parágrafo existente sobre colisão de worktree — confirmar `git branch --show-current` (ou o output do próprio `checkout`) antes de rodar qualquer comando seguinte que dependa do branch atual (`pull`, `merge`, `push` sem branch explícito), já que um `checkout` que falha por colisão de worktree não é um erro fatal de shell.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.27.1` → `1.27.2` (patch).
- **Por quê**
  Closes #253
  Durante a transição entre `/btt-sdd:code-review` e `/btt-sdd:qa` da fatia F-1 de `0003-selecao-cor-disponivel-reserva` (`projeto-B`, PR #105), um `git checkout <branch-da-fatia>` falhou por colisão de worktree, mas o `git pull origin <branch-da-fatia>` seguinte rodou mesmo assim — sobre `main`, não sobre a branch da fatia — avançando `main` local vários commits à frente do `origin/main` com código de uma fatia ainda não aprovada. Nada foi perdido nem enviado a `origin/main` (só notado por checagem adicional de `git status`/`git log`), mas um `git push origin main` subsequente teria violado a regra 1 de `GIT-WORKFLOW.md`.

(PR #257)

## 1.27.1 — 2026-09-21

- **O que mudou**
  - `.claude/skills/sdd-security/SKILL.md` (+ réplica `plugins/btt-sdd/skills/security/SKILL.md`), passo 5: a menção à próxima etapa (`/sdd-sre`) vira um aviso explícito e destacado ("⚠️ Segurança aprovada — o merge deste PR não deveria acontecer ainda; o SRE ainda não rodou"), em vez de ser só a última frase de um resumo maior.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.27.0` → `1.27.1` (patch — reforço, não capacidade nova).
- **Por quê**
  Closes #252
  Amplia o escopo de #138 (fechada, tratava só o fluxo de hotfix): na fatia `dedicated-chrome-profile` (T-34/T-35, `projeto-B` PR #81) — uma fatia **normal com TRD**, não hotfix — o PR foi mergeado logo depois da aprovação de segurança, sem que o SRE tivesse rodado. A causa raiz não é específica de hotfix: nenhuma etapa do pipeline normal deixa claro, de forma difícil de ignorar, que o SRE ainda não rodou antes do usuário decidir mergear.

(PR #256)

## 1.27.0 — 2026-09-19

- **O que mudou**
  - **`ux-designer` ganha um segundo modo** ("consultoria de PRD"), distinto do modo revisão pós-implementação (etapa 4b, que continua igual): sem PR/branch, sem `ux-review.md`, sem veredito aprovado/reprovado — só um parecer de navegabilidade/usabilidade (mesmas 7 heurísticas de Nielsen, escopadas ao que é avaliável antes de qualquer código existir).
  - **`/sdd-prd` passo 2b** invoca `ux-designer` nesse modo **sempre que a feature tem alteração de UI de verdade** (mesmo gate que já existia para oferecer wireframes) — independente de o usuário topar ver wireframes ou não:
  - Se topar: `ux-designer` revisa as opções geradas pela skill `design` **antes** de perguntar ao usuário qual prefere, e o parecer de cada opção entra na descrição apresentada.
  - Se recusar: `ux-designer` ainda dá parecer sobre a descrição textual das telas/fluxos do pedido.
  - **`product-design`** registra esse parecer na nova subseção **"Parecer de UX (`ux-designer`)"** da seção 7 do PRD (`specs/_template/prd.template.md`) — informativo, nunca bloqueia a aprovação do PRD.
  - Réplica completa em `plugins/btt-sdd/` (agente, skill `prd`, template do scaffold que `/create-project` distribui) — e, de passagem, corrigido um bug pré-existente na cópia do plugin de `ux-designer.md` (PR #245 tinha copiado `/sdd-*` sem traduzir para `/btt-sdd:*`).
  - Docs atualizados: `docs/SDD-WORKFLOW.md` (etapa 1), `docs/QUALITY-GATES.md` (seção PRD), `docs/FILE-GUIDE.md` (agentes `product-design`/`ux-designer`), `CLAUDE.md` (tabela de comandos + diagrama).
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.26.3` → `1.27.0` (minor — capacidade nova).
- **Por quê**
  Closes #250
  Pedido direto do usuário nesta sessão: hoje `ux-designer` só participa depois que o código já existe (tarde demais para influenciar a estrutura das histórias ou a escolha do wireframe). O usuário confirmou explicitamente o gate: **só quando há alteração de UI de verdade** — mesmo critério que já existia para a oferta de wireframes, sem condição nova.

(PR #251)

## 1.26.3 — 2026-09-19

- **O que mudou**
  - Novo passo **1b** em `.claude/agents/architect.md` (+ réplica `plugins/btt-sdd/agents/architect.md`), logo após ler o PRD: antes de basear uma decisão de arquitetura de automação de navegador numa premissa técnica que o PRD só validou manualmente (ex.: "login não é pré-requisito"), o `architect` confirma explicitamente se essa mesma premissa se sustenta sob o motor de automação real (Playwright/Selenium) — não só manualmente por um humano navegando normalmente — antes de afirmá-la como validada no TRD. Se não for possível confirmar ainda, registra como VALIDAR DEPOIS em vez de assumir.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.26.2` → `1.26.3` (patch).
- **Por quê**
  Closes #240
  Na spec `0001-automacao-form-reserva-ml` do projeto `projeto-B`, uma validação manual de premissa (login não exigido, testado abrindo a URL sem estar logado) embasou uma migração de arquitetura completa (ADR 0009: eliminar CDP attach em favor de lançamento isolado do Chrome via Playwright) — implementada, revisada e mergeada. No teste geral pós-merge, a automação real foi bloqueada pelo Mercado Livre mesmo carregando os mesmos cookies, forçando reverter a arquitetura por completo (duas migrações completas, cada uma com ciclo inteiro de revisão). O padrão: validação manual confirma condição necessária, não suficiente, quando a decisão elimina um mecanismo que preservava "parecer" tráfego humano.

(PR #249)

## 1.26.2 — 2026-09-19

- **O que mudou**
  - `sdd-status.sh`/`.ps1` (repositório + plugin): nova etapa `ux-review` na lista `STAGES`, entre `code-review` e `qa-report`, com o mesmo tratamento das demais — inclui um caso especial para o heading `## Decisão: UX review pulado (justificado)` (mesmo padrão de "QA pulado", mas **não terminal**: o pipeline segue para `/sdd-qa` normalmente, diferente de QA pulado que é estado final).
  - `sdd-pending.sh`/`.ps1` (repositório + plugin) e `SKILL.md` correspondente: `ux-review.md` adicionado à lista de artefatos varridos por pendências "VALIDAR DEPOIS".
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.26.1` → `1.26.2` (patch).
- **Por quê**
  Closes #244
  Último PR do lote de UX review (#241, #242, #243). Sem esta mudança, uma fatia com `ux-review.md` presente ficaria invisível para `/sdd-status`/`/sdd-pending` — mesmo tipo de lacuna que `skills/hotfix/SKILL.md` já documenta ter acontecido de verdade com SRE (achado só ~9 dias depois do merge).

(PR #248)

## 1.26.1 — 2026-09-19

- **O que mudou**
  - `.claude/skills/sdd-hotfix/SKILL.md` (+ réplica `plugins/btt-sdd/skills/hotfix/SKILL.md`), passo 5: novo critério objetivo **UX/Usabilidade** ao lado de QA/Segurança/SRE — roda `/sdd-ux-review` sempre que o diff alterar uma tela/fluxo com superfície de UI perceptível; caso contrário, registra "não aplicável" no mesmo padrão já usado para "QA pulado" (`## Decisão: UX review pulado (justificado)`).
  - Passo 6 (lista de revisões a rodar) e passo 6b (checagem final antes de mencionar merge) atualizados para incluir `ux-review.md`/`/sdd-ux-review` — mesmo raciocínio já documentado ali sobre o incidente real de um SRE nunca ter sido acionado antes de um merge (achado só ~9 dias depois).
  - Passo 1 (lista de artefatos editados in-place na spec relacionada) também inclui `ux-review.md`.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.26.0` → `1.26.1` (patch — wiring de uma capacidade já existente em outra skill, não uma capacidade nova).
- **Por quê**
  Closes #243
  Terceiro PR do lote de UX review (#241 agente, #242 skill própria). Sem este passo, uma correção pontual via `/sdd-hotfix` que muda UI perceptível (exatamente o tipo de mudança que motivou #241 — alinhamento de navegação, visibilidade condicional de ações) não tinha nenhum gate de UX, só o code review genérico.

(PR #247)

## 1.26.0 — 2026-09-19

- **O que mudou**
  - Nova skill `.claude/skills/sdd-ux-review/SKILL.md` (+ réplica `plugins/btt-sdd/skills/ux-review/SKILL.md`), seguindo o mesmo padrão de `sdd-code-review`/`sdd-qa`: confirma PR sincronizado, invoca `ux-designer` sempre com `isolation: "worktree"`, produz `specs/<slug>/ux-review.md`, registra duração em `timing-log.md`.
  - Critério objetivo de quando a etapa se aplica (superfície de UI perceptível) vs. "não aplicável" (heading padronizado `## Decisão: UX review pulado (justificado)`, mesmo padrão já usado para QA pulado em `/sdd-hotfix`).
  - Novo template `specs/_template/ux-review.template.md` (+ cópia em `plugins/btt-sdd/skills/create-project/scaffold/specs/_template/`, única árvore que `/create-project` copia para projetos novos).
  - **Decisão de design** (issue #242 oferecia duas opções): tratar como etapa **"4b"** entre code review (4) e QA (5), **sem renumerar** as etapas 5→6→7 — opção que a própria issue já marcava como menos disruptiva para specs já em andamento.
  - Integração em `CLAUDE.md` (diagrama do pipeline, tabela de comandos, parágrafo "etapas 4-7 sempre passam pela skill própria"), `docs/SDD-WORKFLOW.md` (nova seção 4b + atualizações em "Ciclo de feedback" e "GitHub Flow no pipeline"), `docs/QUALITY-GATES.md` (nova seção "UX / Usabilidade" + ajustes nos gates de QA/Merge/Status de tarefas/CI-paths/auto-aprovação que já enumeravam os outros agentes de revisão por nome), `docs/FILE-GUIDE.md` (agente, skill e template novos), e o `CLAUDE.md` gerado por `/create-project` (`plugins/btt-sdd/skills/create-project/scaffold/CLAUDE.md`).
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.25.0` → `1.26.0` (minor — a etapa só fica de fato utilizável com esta skill, mesmo o agente já existindo desde #241).
- **Por quê**
  Closes #242
  Continua o lote de #241: o agente `ux-designer` sozinho não tinha forma padrão de ser acionado dentro do pipeline. Esta PR fecha esse ciclo — cria a skill, o artefato, e documenta a etapa em todos os pontos onde as demais etapas de revisão já são descritas, para não ficar uma etapa "invisível" à parte do resto do fluxo.

(PR #246)

## 1.25.0 — 2026-09-19

- **O que mudou**
  - Novo agente `.claude/agents/ux-designer.md` (+ réplica `plugins/btt-sdd/agents/ux-designer.md`), seguindo o mesmo padrão dos demais agentes de revisão (`code-reviewer`, `qa-engineer`): frontmatter, seção de docs de governança, pré-condição de entrada, "O que você NUNCA faz", governança de decisão, 7 áreas de revisão (heurísticas de Nielsen aplicadas concretamente), processo e definição de pronto.
  - Preferência explícita por verificação ao vivo (automação de navegador, quando disponível no ambiente) sobre inferir comportamento só lendo JSX/CSS — critério pedido na issue, já que vários dos achados que motivaram este agente só apareceram usando o app de verdade.
  - `plugins/btt-sdd/.claude-plugin/plugin.json`: `1.24.16` → `1.25.0` (minor — nova capacidade, não só ajuste).
- **Por quê**
  Closes #241
  Nenhuma etapa do pipeline hoje avalia usabilidade/navegabilidade percebida — só qualidade de código, critério de aceite, segurança e infra. Uma sessão real de uso do projeto `projeto-A` encontrou, numa checagem manual fora do pipeline, problemas reais (navegação desalinhada, ações não adaptadas ao ciclo de vida do domínio, mídia corrompida sem fallback, hierarquia de menu sem separação de risco) que nenhuma etapa existente tinha motivo para pegar.
  Este PR só cria o agente (issue #241) — a skill `/btt-sdd:ux-review` que o aciona é a issue #242, próxima do lote.

(PR #245)

## 1.24.16 — 2026-09-19

- `sre` agora roda `actionlint` (ou lint equivalente disponível para a stack) sempre que editar/criar qualquer arquivo em `.github/workflows/*.yml` — não só `ci.yml`/`cd.yml`, qualquer workflow — antes de considerar a mudança pronta para commit.
- Replicado em `plugins/btt-sdd/agents/sre.md` (versão do plugin incrementada para 1.24.16, patch).

(PR #239)

## 1.24.15 — 2026-09-19

- Traz de volta o conteúdo substantivo que existia em `docs/GIT-WORKFLOW.md` e nunca foi replicado para `plugins/btt-sdd/docs/GIT-WORKFLOW.md`: blocos inteiros da seção "Isolamento de working tree entre agentes concorrentes" (worktree órfão no Windows, `git checkout main` bloqueando o worktree principal, conflitos de merge em artefato de revisão, conflito de rebase fatia vs. hotfix, branch presa a worktree isolado), a seção "Revisão retroativa de um PR já mergeado", e detalhes truncados na tabela de mapeamento e na seção final de issue-antes-de-branch.
- Preserva as substituições de nomenclatura já corretas da cópia do plugin (`/btt-sdd:*` em vez de `/sdd-*`, paths sem `.claude/` como prefixo — ex. `agents/architect.md`, `skills/implement/SKILL.md`).
- Mantém `.claude/worktrees/` inalterado por ser convenção de runtime do harness, não um path de fonte do plugin (confirmado contra outros docs do plugin, ex. `plugins/btt-sdd/docs/TESTING.md`, que já usam esse mesmo path sem substituição).
- Versão do plugin incrementada para 1.24.15 (patch).

(PR #237)

## 1.24.14 — 2026-09-19

- `code-reviewer`, `qa-engineer`, `security-engineer` e `sre` agora resolvem todo path de `specs/<slug>/` relativo ao próprio diretório de trabalho quando rodam num worktree isolado (`isolation: "worktree"`), nunca um path absoluto fixo do repositório principal.
- Se houver motivo para desconfiar do conteúdo retornado por uma ferramenta de leitura com cache, reconfirmar via leitura direta de shell antes de basear qualquer veredito nele.
- Versão do plugin incrementada para 1.24.14 (patch).

(PR #234)

## 1.24.13 — 2026-09-19

- Antes de encerrar, um agente rodando com `isolation: "worktree"` agora permanece na própria branch da fatia (ou usa `git checkout --detach`) em vez de tentar `git checkout <branch base>` dentro do próprio worktree.
- A instrução original (voltar para a branch base) continua valendo quando o agente compartilha o mesmo diretório de trabalho do orquestrador, sem isolamento.
- Toca `backend-developer`, `frontend-developer`, `code-reviewer`, `qa-engineer`, `security-engineer`, `sre` (+ réplicas em `plugins/btt-sdd/agents/`) e `docs/GIT-WORKFLOW.md`.
- Versão do plugin incrementada para 1.24.13 (patch).

(PR #233)

## 1.24.12 — 2026-09-19

- Novo passo 2b-ter em `.claude/skills/sdd-implement/SKILL.md` (e replicado em `plugins/btt-sdd/skills/implement/SKILL.md`): antes de invocar `backend-developer`/`frontend-developer` para a fatia escolhida, confirma via `gh pr list --state open` que não existe já um PR aberto com todos os artefatos de revisão aprovados cobrindo essa mesma fatia.
- Versão do plugin incrementada para 1.24.12 (patch).

(PR #232)

## 1.24.11 — 2026-09-18

- `backend-developer` agora exige, por padrão, dois testes de integração distintos para todo adapter que envolve processo externo/CLI com "resultado vazio esperado" como caso de negócio válido: (1) o caso vazio legítimo, e (2) um caso de falha real do processo — nunca o mesmo sinal para os dois.
- Replicado em `plugins/btt-sdd/agents/backend-developer.md` (versão do plugin incrementada para 1.24.11, patch).

(PR #227)

## 1.24.10 — 2026-09-18

- `architect` agora confirma explicitamente, ao preencher a seção 9 do TRD (schema JSON/API/evento externo), que todo campo exigido tem fonte clara nos DTOs internos definidos nas seções 6/7 — ou está marcado como resolvido na borda do adapter de entrada.
- Adiciona o mesmo checklist item na "Definição de pronto" do agente.
- Replicado em `plugins/btt-sdd/agents/architect.md` (versão do plugin incrementada para 1.24.10, patch).

(PR #226)

## 1.24.9 — 2026-09-17

- Adiciona um passo explícito (6d) ao processo do `architect`: ao desenhar um TRD que remove um
  valor de enum/tipo usado para classificar dados já persistidos (enum de status, tipo de alerta/
  notificação, categoria etc.), o agente confere auto-consistência antes de aprovar o TRD — decide
  explicitamente entre manter o valor válido só para leitura de histórico, ou migrar/purgar os dados
  antes de remover por completo. Nunca afirmar "remover por completo" e "nenhuma migração de dados
  necessária" no mesmo parágrafo sem reconciliar.
  Replicado em `plugins/btt-sdd/agents/architect.md`; versão do plugin `1.24.8` → `1.24.9` (patch).

(PR #223)

## 1.24.8 — 2026-09-17

- Novo bullet em `docs/QUALITY-GATES.md`, seção "Governança de decisão": comando de build/teste que decide o próximo passo do próprio agente sempre roda em primeiro plano, nunca em background.
- O harness considera o turno de um subagente concluído assim que ele para de emitir chamadas de ferramenta, mesmo com um processo real ainda rodando em background — já causou duas notificações falsas de "concluído" numa sessão real, exigindo monitoramento manual de processos do SO.
- Vale para todo agente de implementação ou revisão do pipeline.
- Replicado em `docs/` e `plugins/btt-sdd/docs/`.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #196

(PR #220)

## 1.24.7 — 2026-09-17

- `qa-engineer.md` ganha o passo 3b: para cada item da seção 10 do TRD (pilares de engenharia) que declare um mecanismo concreto — não uma decisão de design abstrata —, confirma que ele existe de fato no código, não só que os critérios de aceite de US passam.
- Esse tipo de requisito não aparece como critério de aceite testável, então ficava fora do radar tanto do `code-reviewer` quanto do `qa-engineer` — só foi pego por acidente numa revisão de segurança que procurava outra coisa.
- Replicado em `.claude/agents/` e `plugins/btt-sdd/agents/`.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #197

(PR #219)

## 1.24.6 — 2026-09-17

- `/sdd-implement`, seção "Retomando para corrigir achados de revisão": novo passo 1c — a janela de `SendMessage` para retomar um agente que acabou de implementar uma fatia pode expirar em menos de 1h de wall-clock, mesmo dentro da mesma sessão, preenchida só por outras duas invocações de subagente.
- Recomenda formular o pedido de correção do passo 1 já pronto para funcionar como prompt de abertura de um agente novo, caso a retomada falhe — evita reformular o pedido do zero no fallback.
- Replicado em `.claude/skills/sdd-implement/` e `plugins/btt-sdd/skills/implement/`.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #198

(PR #218)

## 1.24.5 — 2026-09-17

- `backend-developer`/`frontend-developer` não editam mais a coluna Status do TRD para `implementado` no próprio commit final de fatia (continuam comentando a transição na Issue GitHub) — duas trilhas terminando em paralelo e editando a mesma tabela na última task já causou um conflito mecânico real de merge nessa coluna.
- `/sdd-implement` (passo 5) agora promove essa coluna numa única passada, depois de confirmar as duas trilhas integradas na branch compartilhada — elimina o conflito por completo. Opção 1, recomendada pela própria issue.
- Replicado em `.claude/agents/`, `.claude/skills/sdd-implement/` e `plugins/btt-sdd/`.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #203

(PR #217)

## 1.24.4 — 2026-09-17

- `/sdd-implement`, seção "Retomando para corrigir achados de revisão": novo passo 3b — toda invocação de correção pontual também vira linha em `timing-log.md`, mesmo fora dos passos numerados 1-5.
- `/sdd-code-review`, `/sdd-qa`, `/sdd-security`, `/sdd-sre`: observação equivalente no próprio passo 3b existente — o registro vale também quando a invocação é só uma reverificação pontual de achado específico, não só uma rodada completa.
- Replicado nas 5 skills, junction e plugin.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #204

(PR #216)

## 1.24.3 — 2026-09-17

- `backend-developer`, ao remover uma classe/símbolo sem consumidor de negócio, agora busca referências em todo o repositório (`grep -r`), não só nos diretórios óbvios do caso de uso — handlers centrais de exceções/erros referenciam a classe só por tipo (union type, `match`/`switch`), nunca instanciando, e ficam fora do escopo natural de quem procura só por `throw`/`new`.
- `code-reviewer` ganha a mesma checagem como segunda linha de defesa.
- Replicado em `.claude/agents/` e `plugins/btt-sdd/agents/`.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #205

(PR #215)

## 1.24.2 — 2026-09-17

- Ao montar o plano combinado de uma fatia full-stack (`/sdd-implement`, passo 4b), quando a fatia introduz o endpoint permanente de uma "janela de convivência" já desenhada no TRD, instrui grep explícito pelo caminho da rota temporária em `frontend/src` antes de escrever a instrução da trilha frontend.
- Evita presumir "já existe, sem mudança necessária" só porque a assinatura do método já bate — a rota temporária pode ser removida por uma fatia futura, e um consumidor não migrado quebra silenciosamente em produção.
- Replicado em `.claude/skills/sdd-implement/SKILL.md` e `plugins/btt-sdd/skills/implement/SKILL.md`.
- `plugins/btt-sdd/.claude-plugin/plugin.json` incrementado para 1.23.1 (patch).
Closes #209

(PR #214)

## 1.24.1 — 2026-09-17

- Testei \`/create-project\` de ponta a ponta manualmente (após #202/#208) e encontrei duas classes de referência que sobraram da arquitetura antiga:
  1. \`README.md\` do scaffold: "veja \`docs/FILE-GUIDE.md\`" — esse arquivo não existe mais no projeto novo.
  2. 10 referências em 6 templates de \`specs/_template/\` (\`code-review\`, \`coverage-summary\`, \`qa-report\`, \`security-review\`, \`sre-review\`, \`trd\`) citando \`docs/GIT-WORKFLOW.md\`/\`docs/QUALITY-GATES.md\`/\`docs/TESTING.md\`/\`docs/ARCHITECTURE.md\`/\`docs/ENGINEERING-PILLARS.md\` como se fossem locais. Esse texto vira parte literal de \`code-review.md\`/\`qa-report.md\`/etc. reais gerados em qualquer projeto novo, confundindo quem for ler depois.
  Troca \`docs/X.md\` por \`X.md\` do pipeline\` nessas referências. Mantidas intactas as referências a \`docs/STACK.md\`/\`docs/LESSONS-LEARNED.md\`, que continuam genuinamente do projeto (verificado explicitamente, não uma varredura cega).
  Arquivos tocados:
  - \`plugins/btt-sdd/skills/create-project/scaffold/README.md\`
  - \`plugins/btt-sdd/skills/create-project/scaffold/specs/_template/{code-review,coverage-summary,qa-report,security-review,sre-review,trd}.template.md\`
  - \`plugins/btt-sdd/.claude-plugin/plugin.json\`: patch \`1.23.0\` -> \`1.23.1\`
  Closes #210

(PR #211)

## 1.24.0 — 2026-09-17

- `codebase-archaeologist` ganha uma segunda responsabilidade, separada de `docs/BASELINE.md`: gerar/atualizar `docs/PROJECT-CONVENTIONS.md`, registrando **só as divergências** deste projeto em relação ao padrão genérico do pipeline (git workflow, estrutura de pastas etc.) — nunca o sistema em si.
- Novo comando `/sdd-project-conventions` (e `/btt-sdd:project-conventions` no plugin), usável a qualquer momento.
- `/create-project` passa a semear `docs/PROJECT-CONVENTIONS.md` automaticamente ao final do scaffold (tipicamente "nada a registrar ainda" num projeto recém-criado).
- `/sdd-baseline` também pode gerar/atualizar esse arquivo de carona, aproveitando a inspeção que já está fazendo.
- Documentação atualizada em `CLAUDE.md`, `docs/FILE-GUIDE.md`, `docs/SDD-WORKFLOW.md` (raiz e cópia do plugin) e no `CLAUDE.md` do scaffold de `/create-project`.
- Versão do plugin (`plugins/btt-sdd/.claude-plugin/plugin.json`) de `1.23.0` para `1.24.0`, por tocar conteúdo empacotado.

(PR #222)

## 1.23.0 — 2026-09-17

- Substitui PR #207, que o GitHub fechou automaticamente quando o merge de #202 (squash) apagou a branch que servia de base para esta PR empilhada. Mesmo conteúdo de #207, mais a reconciliação de conflitos reais contra o `master` atual (que já incluía tanto #200 quanto #202 mergeados).
  Elimina a necessidade de `/sdd-sync-docs`: os docs de governança genéricos do pipeline (`GIT-WORKFLOW.md`, `QUALITY-GATES.md`, `TESTING.md`, `ENGINEERING-PILLARS.md`, `ARCHITECTURE.md`, `SDD-WORKFLOW.md`, `FILE-GUIDE.md`, `POST-MERGE-VALIDATION.md`) deixam de ser copiados para dentro de cada projeto novo -- passam a viver bundled com a própria distribuição de agentes/skills (`plugins/btt-sdd/docs/` para instalação via plugin; a raiz `docs/` deste repositório para a distribuição via junction), lidos diretamente de onde estão instalados em vez de uma cópia congelada no projeto. Isso elimina o problema que motivava o sync: não existe mais cópia nenhuma para desatualizar.
  Closes #206

(PR #208)

## 1.22.12 — 2026-09-17

- **Estrutural, sem impacto para quem já scaffolded**: este repositório deixou de manter uma
  segunda cópia local do scaffold (`.claude/skills/create-project/scaffold/`) — `/create-project`
  agora lê direto do scaffold deste plugin, que passa a ser a única fonte, mesmo quando invocado
  via junction sem o plugin instalado. Isso não muda o conteúdo entregue a um projeto novo.
- Reconciliação de conteúdo que havia divergido entre as duas cópias antes desta unificação (issue
  #201) — projetos scaffolded a partir da cópia local (agora removida) estavam sem: (a) os itens
  de governança "Nenhum agente encerra numa branch de feature" e "Nenhum agente aprova/reprova o
  próprio trabalho" em `docs/QUALITY-GATES.md`; (b) a correção de frescor de cobertura por commit
  mais recente que tocou `src/`/`frontend/` em vez de HEAD literal (issue #172) em
  `docs/TESTING.md` e `docs/QUALITY-GATES.md`; (c) as colunas `Profundidade`/`Commit` no histórico
  de aprovações por fatia de `security-review.template.md`/`sre-review.template.md`.

## 1.22.11 — 2026-09-17

- `docs/GIT-WORKFLOW.md` e `CLAUDE.md`, seção "Mudanças no próprio pipeline"/regra 5: novo
  requisito — confirmar (ou criar) uma issue do GitHub descrevendo o porquê da mudança antes de
  criar a branch, e referenciar `Closes #N` no PR. Estende a exigência já aplicada a `/sdd-hotfix`
  para qualquer mudança de manutenção no próprio pipeline (agentes/skills/docs/templates), que até
  então não tinha esse gate. (issue #199)

## 1.22.4 — 2026-09-15

- `docs/QUALITY-GATES.md`, seção "Revisão de código": novo item — uma fatia que estende um
  guard/regra de autorização já implementado por uma fatia anterior precisa renomear os testes
  cujo nome descreve o comportamento invertido pela nova fatia (não só alterar a asserção), e
  confirmar via grep que nenhuma referência órfã ao nome antigo do teste ficou para trás. (issue
  #177)

## 1.22.2 — 2026-09-15

- `docs/QUALITY-GATES.md`, seção "Governança de decisão": novo item — reconfirmar um ponto técnico
  já documentado em detalhe por uma etapa anterior (`code-review.md`/`qa-report.md`/
  `security-review.md`) com veredito "sem achado" não exige reescrever a explicação inteira; a
  verificação independente continua obrigatória, mas a conclusão pode ser registrada por referência
  cruzada ao relatório anterior, reduzindo tamanho de artefato e custo de geração. (issue #173)

## 1.21.4 — 2026-09-10

- `docs/QUALITY-GATES.md`, seção "Lições aprendidas recorrentes": o mecanismo de escalonamento de
  3 ocorrências (issue #140) agora também cobre entradas `acionável-por-agente`, não só `depende de
  ação externa` — "virar entrada e ser lida no planejamento" evita o bug em código novo, mas não
  corrige consumidores já existentes com o mesmo padrão. Na 3ª ocorrência confirmada sem correção
  efetiva, o agente de revisão propõe explicitamente uma mini-fatia/hotfix dedicada via
  `AskUserQuestion`. (issue #151)

## 1.21.2 — 2026-09-10

- `docs/QUALITY-GATES.md`, seção "SRE / CI-CD / Infra": novo item exigindo que `ci.yml` tenha
  filtro de `paths`/`paths-ignore` cobrindo `specs/**`, `docs/**` e `*.md` da raiz — sem isso, cada
  push de um artefato de revisão (`code-review.md`/`qa-report.md`/`security-review.md`/
  `sre-review.md`) dispara um run completo de CI desnecessário. Confirmado ao vivo: um PR só com
  `qa-report.md` atualizado disparou ~4min de CI sem necessidade. (issue #146)

## 1.21.1 — 2026-09-10

- `docs/QUALITY-GATES.md`, seção "Status de tarefas": documenta o caso especial da última fatia de
  uma spec, que nunca tem "fatia seguinte" para disparar a promoção de Status para `concluído
  (mergeado)` — `/sdd-implement` (passo 2a) agora cobre isso, confirmando o merge real via `gh pr
  view` e promovendo retroativamente antes de informar "nada a fazer". Já causou falso-positivo
  sistemático em 7 specs de um mesmo projeto, todas 100% mergeadas mas reportadas como "próxima
  fatia pendente" indefinidamente. (issue #144)

## 1.21.0 — 2026-09-10

- `docs/QUALITY-GATES.md`: entradas de "Lições aprendidas recorrentes" ganham o campo "Classe"
  (`acionável-por-agente` vs. `depende de ação externa`), e uma entrada `depende de ação externa`
  que atinge 3 ocorrências confirmadas aciona `AskUserQuestion` oferecendo resolver a pendência
  diretamente (ex.: `sre` configurando proteção de branch/environment via API do GitHub, sujeito a
  aprovação explícita) em vez de só acrescentar mais uma linha passiva à tabela. (issue #140)

## 1.20.20 — 2026-09-10

- `docs/QUALITY-GATES.md`: novo item na seção "Lições aprendidas recorrentes" — uma entrada de
  `docs/LESSONS-LEARNED.md` nunca substitui a regra canônica que ela generaliza; se a entrada (ou
  sua paráfrase por qualquer agente) parecer contradizer ou estreitar uma regra já formalizada em
  outro doc do projeto (`docs/TESTING.md`, `docs/QUALITY-GATES.md`, etc.), a regra canônica
  prevalece e a divergência é sinal de corrigir a entrada, não de que a regra mudou. (issue #133)

## 1.20.12 — 2026-09-08

- `docs/TESTING.md`: nova seção "Frontend (quando aplicável)" explica que, sem um harness de e2e
  de browser real contra backend real, uma tarefa de TRD descrita como "e2e do fluxo humano" exige
  que o `architect` já especifique o mecanismo de verificação alternativo (ex.: integração HTTP
  encadeada) na própria tarefa, em vez de deixar implícito. (issue #115)

## 1.20.10 — 2026-09-08

- `docs/QUALITY-GATES.md`: novo item bloqueante no gate SRE/CI-CD/Infra — quando uma fatia torna
  obrigatório um campo antes opcional/ausente numa rota já ativa consumida por um cliente já
  implantado que ainda não foi atualizado, e os gates de deploy automático já estão ligados, o
  `sre` exige um default retrocompatível ou confirmação explícita do usuário antes do merge, em
  vez de registrar como nota não-bloqueante de coordenação de deploy. (issue #113)

## 1.20.9 — 2026-09-08

- `docs/ENGINEERING-PILLARS.md`: seção "Disponibilidade" ganha um parágrafo apontando que, em
  features multi-fatia, o TRD também precisa endereçar janelas de quebra de contrato *entre*
  fatias (não só a disponibilidade da feature inteira) — ver "Janelas de quebra de contrato entre
  fatias" na seção 13 de `specs/_template/trd.template.md`. (issue #109)

## 1.20.7 — 2026-09-08

- `docs/GIT-WORKFLOW.md`: a seção "Isolamento de arquivos não é isolamento de serviços com estado"
  agora deixa explícito que o `architect` decide e registra em `docs/STACK.md` o mecanismo de
  isolamento de serviço com estado (banco/fila/emulador) entre execuções concorrentes assim que a
  stack do projeto passa a depender de um, em vez de deixar essa decisão totalmente implícita
  esperando alguém perceber a lacuna só depois de uma contenção real entre agentes. (issue #107)

## 1.20.5 — 2026-09-07

- `docs/DOCS-SYNC.md`: corrige a condição que dispara a comparação estrutural completa de
  `/sdd-sync-docs` — passa a rodar também quando `docs/.sdd-plugin-version` está presente mas
  anterior a `1.15.0` (não só quando o marcador está ausente), e passa a checar também a direção
  scaffold → projeto (arquivo inteiro do scaffold ausente no projeto), não só seções dentro de
  arquivos que já existem nos dois lados. Sem essa correção, um projeto cujo marcador foi gravado
  antes da `1.15.0` existir nunca recebia essa varredura, mesmo depois de atualizar o plugin várias
  vezes — achado real num projeto com 30 seções/arquivos de scaffold ausentes, todos anteriores a
  `1.14.0`.

## 1.20.2 — 2026-09-07

- `docs/QUALITY-GATES.md`: gate novo na seção "Governança de decisão" — merge de PR nunca é ação
  de um agente, mesmo o próprio agente que implementou o ajuste sendo revisado; documenta como
  risco conhecido de agentes autônomos com escrita em sistemas compartilhados, a partir de um
  incidente real em que o agente `sre` mergeou um PR sozinho apesar de instrução explícita em
  contrário. Exceção deliberada continua sendo a skill `/repo-issues`.

## 1.20.0 — 2026-09-07

- `docs/QUALITY-GATES.md`: gate novo na seção "PRD" — se a feature tem UI e wireframes são
  oferecidos, mas `docs/DESIGN-SYSTEM.md` ainda não existir no projeto, o usuário precisa ser
  consultado sobre estabelecer um sistema de design (paleta de cores, tipografia, tom visual,
  referências) antes de gerar as opções de wireframe, com recusa explícita sempre disponível
  (`/sdd-prd` passo 2b). Uma vez estabelecido, `docs/DESIGN-SYSTEM.md` é reaproveitado pelas
  próximas features com UI sem perguntar de novo — mesmo padrão de `docs/STACK.md`.

## 1.19.2 — 2026-09-07

- `docs/QUALITY-GATES.md`: toda issue GitHub que o pipeline cria no repositório do projeto-alvo
  passa a exigir identificação estruturada da spec de origem, não só as de tarefa do TRD —
  reaproveitar o milestone da spec quando existir, ou aplicar um label `spec:<slug>` quando não
  houver milestone ainda (ex.: issue de `/sdd-hotfix` associada a uma spec sem decomposição de
  tarefas em issues).

## 1.19.0 — 2026-09-07

- `docs/QUALITY-GATES.md`: criar Issue GitHub para toda tarefa do TRD deixa de ser opcional —
  sem remote GitHub configurado/autenticado, o TRD não pode ser aprovado (só o PRD dispensa
  GitHub); `/sdd-implement`/`/sdd-hotfix` não iniciam nenhuma fatia/correção sem a issue já
  existir.

## 1.15.2 — 2026-09-04

- `docs/GIT-WORKFLOW.md`: nova subseção em "Isolamento de working tree entre agentes concorrentes"
  — isolamento de `git worktree` cobre arquivos/estado de Git, não serviços com estado
  compartilhados no host (banco de teste, emulador de nuvem local); cada agente/worktree que roda
  testes de integração contra um desses serviços precisa de instância/banco/schema isolado por
  execução.

## 1.15.1 — 2026-09-04

- `docs/GIT-WORKFLOW.md`: nova subseção em "Aguardando CI antes do merge" — timeout de job de CI
  sob alta concorrência do próprio pipeline (múltiplas fatias/PRs rodando CI em paralelo) é um
  falso-negativo conhecido; tentar `gh run rerun --failed` antes de investigar como bug de código.

## 1.15.0 — 2026-09-03

- `docs/DOCS-SYNC.md`: nova subseção "Comparação estrutural na primeira sincronização" — cobre a
  lacuna de projetos scaffolded antes do início do rastreamento deste changelog (`1.14.0`):
  `/sdd-sync-docs`, na primeira sincronização de um projeto (`docs/.sdd-plugin-version` ausente),
  agora também compara títulos de seção entre os docs do projeto e o scaffold atual, além de ler
  este changelog.

## 1.14.1 — 2026-09-03

- `docs/TESTING.md`: nova subseção "Armadilha conhecida: `testPathIgnorePatterns` do Jest com
  `<rootDir>` e path com segmento iniciado por ponto" (dentro de "Frontend (quando aplicável)") —
  documenta uma falha silenciosa do Jest no Windows quando `rootDir` contém um segmento iniciado
  por ponto (ex. `.claude/worktrees/<id>`, a convenção deste pipeline para isolamento de working
  tree), e o padrão seguro recomendado para `testPathIgnorePatterns`/`modulePathIgnorePatterns`.

## 1.14.0 — 2026-09-03

- `docs/DOCS-SYNC.md` (arquivo novo): introduz o marcador `docs/.sdd-plugin-version` e o
  mecanismo de sincronização de docs em si — este changelog é a peça de dados que o mecanismo lê.
- `CLAUDE.md`: nova linha `/sdd-sync-docs` na tabela de comandos.
