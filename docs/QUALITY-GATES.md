# Quality Gates — validações críticas do pipeline

Checklist único e não-negociável. Qualquer agente (ou pessoa) trabalhando neste repositório
verifica isto antes de avançar uma etapa. Um gate marcado aqui como bloqueante **bloqueia mesmo**
— não é sugestão, é a definição do que "pronto" significa neste pipeline. Os "Definition of Done"
de cada agente (`.claude/agents/*.md`) são a aplicação específica destes gates à etapa dele; este
documento é a referência única para não duplicar a lista em cada um deles.

## Governança de decisão (vale para todas as etapas, incluindo a condicional de baseline)

- [ ] **Nenhuma suposição não documentada.** Toda ambiguidade que mudaria o artefato (requisito,
  decisão técnica, interpretação de critério de aceite, decisão de infraestrutura) vira uma
  pergunta explícita ao usuário — nunca uma escolha silenciosa do agente.
- [ ] **"VALIDAR DEPOIS" é sempre uma opção válida.** Quando o usuário não sabe responder agora,
  o agente registra o item na seção "Pendências de validação (VALIDAR DEPOIS)" do artefato, com
  contexto suficiente para retomar sem re-explicar tudo. O item some da lista de pendências só
  quando resolvido via `/sdd-amend` (ver `docs/SDD-WORKFLOW.md`).
- [ ] **Nenhuma ação ou requisição se repete mais de 3 vezes.** Tentativas de corrigir o mesmo
  teste, rodar o mesmo comando, ou reformular a mesma pergunta contam como a mesma ação. Na 3ª
  falha consecutiva, o agente para e escala ao usuário: o que foi tentado, por que falhou, e o
  que ele recomenda como próximo passo. Isso vale tanto para ações técnicas (fix de teste, `apply`
  de infraestrutura) quanto para tentativas de obter uma resposta clara do usuário.
- [ ] **Todo plano de ação real (código, infraestrutura) é aprovado antes de executar.** PRD e TRD
  já são planos por natureza — sua aprovação é o próprio gate. Para `/sdd-implement` e `/sdd-sre`,
  o agente apresenta o plano (incrementos, branch, ou mudança de infra proposta) e obtém aprovação
  explícita do usuário antes de escrever código ou tocar infraestrutura real.
- [ ] **Artefatos aprovados são editados in-place, nunca recriados do zero.** Mudar uma decisão já
  aprovada usa `/sdd-amend`, que registra a mudança no "Log de revisões" e só reabre as etapas
  posteriores realmente afetadas — etapas anteriores aprovadas continuam válidas.

## Lições aprendidas recorrentes (`docs/LESSONS-LEARNED.md`)

Mecanismo de memória do próprio projeto: captura padrões de achados que já se repetiram entre
features, para que `backend-developer`/`frontend-developer` os evitem desde o início da próxima
implementação, em vez de descobri-los de novo numa rodada de revisão. `docs/LESSONS-LEARNED.md`
não existe por padrão — só nasce na primeira vez que uma 2ª ocorrência é confirmada (mesmo padrão
de `docs/STACK.md`/`docs/BASELINE.md`: ausência do arquivo já é sinal de "nenhum padrão recorrente
confirmado ainda").

- [ ] **Só vira entrada com 2 ocorrências confirmadas, nunca na primeira vez que aparece.** Antes
  de registrar um achado, o agente de revisão (`code-reviewer`/`qa-engineer`/`security-engineer`/
  `sre`) verifica se `docs/LESSONS-LEARNED.md` já existe e se alguma entrada da sua própria área
  já descreve o mesmo padrão — se sim, cita o ID da entrada no achado desta rodada e acrescenta
  esta feature/fatia à lista de ocorrências da entrada. Se não há entrada correspondente, verifica
  se um achado essencialmente igual já apareceu numa revisão anterior de **outra** feature/fatia
  (grep em `specs/*/<mesmo-tipo-de-artefato>.md`, excluindo a feature atual). Só ao confirmar essa
  2ª ocorrência cria uma nova entrada (criando o arquivo se for a primeira entrada de sempre),
  citando as duas ocorrências e uma recomendação objetiva de implementação. Achado isolado (1ª
  ocorrência) nunca vira entrada — fica só no relatório da própria feature.
- [ ] **Formato de entrada**: uma seção por área (Backend / Frontend / Segurança / Infra-SRE /
  Testes-QA), com ID sequencial global (`L-001`, `L-002`, ...) e os campos "Detectado por",
  "Ocorrências" (caminho do artefato + fatia, por feature), "Padrão observado" e "Recomendação
  para implementação".
- [ ] `docs/LESSONS-LEARNED.md`, quando criado ou atualizado, é commitado junto do artefato de
  revisão da própria rodada (`code-review.md`/`qa-report.md`/`security-review.md`/
  `sre-review.md`) — nunca num commit separado.
- [ ] `backend-developer`/`frontend-developer` leem `docs/LESSONS-LEARNED.md`, se existir, na fase
  de planejamento (antes de quebrar o TRD em incrementos) e aplicam as lições da(s) área(s)
  relevante(s) à trilha como restrição adicional ao TRD, citando no plano apresentado ao usuário
  qual lição foi aplicada e como.

## Status de tarefas (coluna "Status" da decomposição do TRD)

Toda tarefa da tabela "Decomposição de tarefas e dependências" do TRD tem uma coluna **Status**,
fonte de verdade de onde cada atividade da spec está — nunca inferida depois por outra etapa, só
gravada por quem causa a transição.

- [ ] `architect` inicializa toda tarefa nova como `pendente`.
- [ ] `backend-developer`/`frontend-developer` atualizam, in-place no TRD, para `em andamento` ao
  começar a Fase 2 (execução) das tarefas da fatia — inclusive ao retomar uma tarefa que estava
  `bloqueado` — e para `implementado` ao concluir sua trilha.
- [ ] `code-reviewer`/`qa-engineer`/`security-engineer`/`sre` atualizam para `bloqueado` (com o
  motivo em uma linha) as tarefas da fatia cujo veredito desta rodada foi reprovado.
- [ ] `sre` atualiza para `aprovado` as tarefas da fatia ao aprová-la (ou aprovar com ressalvas) —
  o último gate antes do merge.
- [ ] `/sdd-implement`, ao confirmar (pré-condição antes de iniciar a fatia seguinte) que o PR de
  uma fatia já foi mergeado em `main`, atualiza essa fatia para `concluído (mergeado)`.
- [ ] Se a tarefa tem Issue GitHub associada (coluna "Issue GitHub" preenchida), a mesma transição
  é comentada na issue (`gh issue comment`) pelo mesmo agente/skill que a causou — mesma
  tolerância de falha de 3 tentativas das demais interações com `gh` no pipeline (relate o erro e
  siga sem bloquear a transição por isso).
- [ ] `/sdd-implement`, ao final de cada rodada de implementação, apresenta ao usuário uma tabela
  com o Status atual de **todas** as tarefas da spec (não só as desta fatia) — visão de progresso
  ponta a ponta, não só do incremento mais recente.

## Baseline (condicional, `codebase-archaeologist`)

- [ ] Só roda quando falta documentação base suficiente sobre código/sistema já existente — nunca
  gera `docs/BASELINE.md` redundante quando a documentação já é suficiente.
- [ ] Nada do código existente é corrigido/refatorado — só documentado como é.
- [ ] Toda ambiguidade de intenção virou pergunta ou item VALIDAR DEPOIS.

## PRD

- [ ] Todo critério de aceite é verificável por um terceiro sem contexto adicional (idealmente
  Gherkin).
- [ ] Seção "Fora de escopo" preenchida explicitamente.
- [ ] Seção "Indicadores técnicos a observar" preenchida (volumetria, segurança, legal) — mesmo
  que a resposta seja "nenhum indicador relevante", isso precisa estar escrito, não implícito.
- [ ] Aprovação explícita do usuário registrada.

## TRD

- [ ] Stack tecnológica definida (seção 2 do TRD), com a fonte da decisão registrada —
  reaproveitada de `docs/STACK.md` do projeto, reaproveitada de
  `~/.claude/stack-defaults.md` (confirmada com o usuário), ou decidida nesta sessão com o
  usuário. Nunca implícita dentro de Ports/Adapters/Modelo de dados.
- [ ] Todo critério de aceite do PRD tem um caso de uso e um plano de teste correspondente.
- [ ] Todo port tem contrato claro sem vazar detalhe de implementação de adapter.
- [ ] Indicadores técnicos do PRD foram lidos e endereçados (decisão tomada ou explicitamente
  adiada com justificativa, nunca ignorados).
- [ ] Todo pilar de engenharia (`docs/ENGINEERING-PILLARS.md`: performance, escalabilidade,
  resiliência, disponibilidade, observabilidade, manutenibilidade) tem resposta específica para a
  feature, nunca em branco ou genérica.
- [ ] Se a feature inclui frontend, "Contrato Frontend↔Backend" está definido (no TRD ou num ADR
  referenciado) — nunca "a definir depois".
- [ ] "Decomposição de tarefas e dependências" preenchida, com trilha (backend/frontend/ambos) e
  dependências técnicas explícitas para cada tarefa, e a coluna Status inicializada como
  `pendente` para cada tarefa nova (ciclo de vida completo na seção "Status de tarefas" abaixo).
- [ ] Se o TRD depende de código pré-existente sem documentação suficiente, `/sdd-baseline` rodou
  antes (ou a documentação já era suficiente, explicitamente constatado).
- [ ] Nome de branch GitHub Flow definido **por fatia** (`docs/GIT-WORKFLOW.md`) — uma branch/PR
  por fatia, nunca uma única para a feature inteira quando há mais de uma fatia.
- [ ] Aprovação explícita do usuário registrada.

## Implementação

- [ ] Todo código de produção nasceu de um teste que falhou primeiro (TDD).
- [ ] Cobertura de linhas/branches novas ou alteradas ≥ 80%, **por pacote** (`src/` e, se
  aplicável, `frontend/` separadamente).
- [ ] Lint sem erros.
- [ ] Nenhuma violação de fronteira ports & adapters (domain/application sem import de infra).
- [ ] Se a feature é full-stack: todo adapter de entrada que o frontend consome implementa
  exatamente o contrato do TRD — nenhum campo/rota inventado por qualquer um dos dois lados.
- [ ] Branch da fatia criada a partir de `main` atualizada (só depois do PR da fatia anterior já
  mergeado, se houver uma); PR aberto (única branch/PR por fatia, mesmo quando backend e frontend
  desenvolvem em paralelo dentro dela).
- [ ] Se a fatia cobre tarefas com issue do GitHub associada (coluna "Issue GitHub" do TRD), o PR
  referencia `Closes #N` para cada uma — issues ficam abertas até o merge de verdade, nunca
  fechadas manualmente antes disso.
- [ ] Plano de implementação foi aprovado pelo usuário antes do primeiro commit de código (plano
  combinado quando full-stack, orquestrado por `/sdd-implement`).
- [ ] Resultado da suíte completa com cobertura gravado em
  `specs/<slug>/coverage/<fatia>-<trilha>.md` (`docs/TESTING.md`), com o commit SHA da execução —
  formato condensado, nunca o relatório bruto (HTML) colado — para as etapas seguintes
  reaproveitarem em vez de re-executar a suíte.

## Revisão de código (`code-reviewer`)

- [ ] Nenhuma violação de fronteira ports & adapters (domain/application sem import de infra)
  aprovada sem ressalva.
- [ ] Princípios SOLID avaliados de forma funcional (import de fato, não intenção declarada).
- [ ] Qualidade dos próprios testes avaliada (fragilidade, falso positivo) — cobertura numérica é
  do QA, não desta etapa.
- [ ] Se full-stack: contrato Frontend↔Backend do TRD checado como implementado exatamente pelos
  dois lados.
- [ ] Débito técnico introduzido está sinalizado explicitamente (pelo dev ou pela revisão) — débito
  silencioso não documentado é achado bloqueante.
- [ ] `code-review.md` existe, referencia o PR e a fatia desta rodada, e cada área de revisão tem
  veredito com evidência (arquivo/linha) ou "sem achados".
- [ ] `code-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `code-reviewer` antes de devolver o resultado.

## QA

- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) —
  sem isso, o QA não começa.
- [ ] Cobertura medida e comparada ao gate de 80% — sem relatório de cobertura confiável, não há
  aprovação possível.
- [ ] Todo critério de aceite coberto pela fatia desta rodada tem veredito individual com
  evidência (teste ou passo manual).
- [ ] Suíte completa rodou (regressão, inclui fatias anteriores já mergeadas), não só os testes
  desta fatia — reaproveitando o resumo de cobertura já gravado pela implementação
  (`specs/<slug>/coverage/`) quando o commit bate com o HEAD atual; re-executada e regravada só se
  o arquivo estiver ausente ou desatualizado (`docs/TESTING.md`).
- [ ] `qa-report.md` referencia o PR e a fatia desta rodada.
- [ ] `qa-report.md` (e o arquivo de cobertura, se regravado) commitados (só esses arquivos, nunca
  `git add -A`/`.`) e enviados (push) na branch do PR pelo próprio `qa-engineer` antes de devolver
  o resultado.

## Segurança (`security-engineer`)

- [ ] Superfície de ataque/fronteiras de confiança identificadas para a feature.
- [ ] Cada categoria do OWASP Top 10 tem avaliação (aplicável com achado, ou não aplicável com
  justificativa) — nunca em branco.
- [ ] Nenhum segredo em texto claro na aplicação (código, config, log).
- [ ] Autenticação/autorização revisada em todo caminho relevante, quando a feature tem noção de
  identidade/permissão.
- [ ] Toda fronteira de confiança (CLI, request, evento) valida entrada antes de usar.
- [ ] Dependências novas/alteradas checadas por vulnerabilidade conhecida, dentro do que as
  ferramentas disponíveis permitem verificar.
- [ ] `security-review.md` referencia o PR e a fatia desta rodada.
- [ ] Na fatia final que fecha o spec (nenhuma fatia pendente na decomposição de tarefas do TRD),
  a revisão é sempre completa nas 6 áreas — nunca fast-path — cobrindo o diff acumulado desde a
  última revisão registrada como `completo` na tabela "Histórico de aprovações por fatia", não só
  o diff desta última fatia isolada.
- [ ] `security-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `security-engineer` antes de devolver o resultado.

## SRE / CI-CD / Infra

- [ ] CI roda lint + testes + gate de cobertura em todo PR.
- [ ] `main` protegida: sem push direto, PR obrigatório, status checks obrigatórios (verificado,
  não necessariamente configurado pelo agente — configuração real é do administrador do repo).
- [ ] Deploy só roda após CI verde.
- [ ] Nenhuma alteração de infraestrutura real (`terraform apply`) roda sem plano revisado
  (`terraform plan`) e aprovação explícita do usuário.
- [ ] Docker: build multi-stage, imagem mínima, usuário não-root, sem segredo hardcoded.
- [ ] Se a entrega inclui ambiente de desenvolvimento local (`docker-compose.yml`): validado com
  build + subida reais (não só `docker compose config`), exercitando pelo menos um caminho
  funcional de ponta a ponta (não só "o container subiu"); ambiente verificado livre de
  containers/processos órfãos de sessões anteriores antes de subir; teardown completo (incluindo
  qualquer processo iniciado fora do Docker durante a validação) ao final.
- [ ] Terraform: estado remoto configurado, variáveis sensíveis marcadas `sensitive`.
- [ ] Nenhum segredo em texto claro em código, workflow, Dockerfile ou arquivo Terraform.
- [ ] Na fatia final que fecha o spec (nenhuma fatia pendente na decomposição de tarefas do TRD),
  a revisão é sempre completa no checklist — nunca fast-path — cobrindo o diff acumulado desde a
  última revisão registrada como `completo` na tabela "Histórico de aprovações por fatia", não só
  o diff desta última fatia isolada.
- [ ] `sre-review.md` (e qualquer ajuste de `infra/`/`.github/workflows/` desta rodada)
  commitados (arquivos explícitos, nunca `git add -A`/`.`) e enviados (push) na branch do PR pelo
  próprio `sre` antes de devolver o resultado.
- [ ] Se a fatia foi aprovada e tem issues do GitHub associadas a tarefas cobertas por ela,
  `sre` documentou a resolução em cada uma (`gh issue comment`, resumo + link do PR e dos
  artefatos de revisão) antes de finalizar — a issue fecha sozinha quando a fatia mergear, via
  `Closes #N` já incluído no PR pelo `backend-developer`/`frontend-developer`.

## Merge para `main` (por fatia)

- [ ] PR desta fatia aberto, CI verde, revisão de código aprovada, QA aprovado, segurança
  aprovada, SRE aprovado (ou aprovado com ressalvas não-bloqueantes explicitamente aceitas pelo
  usuário em qualquer uma dessas etapas) — tudo escopado a esta fatia, não à feature inteira.
- [ ] Se houver fatia seguinte pendente na feature, ela só começa depois deste merge
  (`docs/GIT-WORKFLOW.md`).
- [ ] Nenhum item "VALIDAR DEPOIS" bloqueante (marcado como tal pelo usuário) segue em aberto.
