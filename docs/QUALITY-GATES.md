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
- [ ] **Nenhum agente encerra numa branch de feature.** Todo agente que faz `git checkout`/
  `git switch` para uma branch de fatia (implementadores e revisores que commitam achados na
  branch do PR) confirma a branch atual (`git branch --show-current`) antes de finalizar e, se não
  for a branch base a partir da qual a branch da fatia foi criada (normalmente `main`), volta para
  ela (`git checkout <branch base>`). Já causou dano real deixar o working directory na branch
  errada (ex.: um `git pull origin main` rodado sem perceber a branch atual gerou um merge commit
  espúrio).
- [ ] **Nenhum agente aprova/reprova o próprio trabalho.** Um agente implementador
  (`backend-developer`/`frontend-developer`, ou `sre` fazendo um ajuste pontual de infra) nunca
  escreve veredito em `code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md` na
  mesma rodada em que implementou a correção — mesmo sendo tecnicamente o mesmo tipo de agente que
  normalmente revisaria aquilo. O gate exige uma instância nova e independente do agente de
  revisão correspondente, invocada depois.
- [ ] **Reverificação de um achado específico já corrigido tem escopo proporcional — não repete a
  suíte inteira do zero a cada rodada.** Isso não relaxa o bullet anterior (a verificação
  independente continua obrigatória, nunca aceita o relato de quem corrigiu como prova); muda só o
  que essa verificação reexecuta. Numa rodada que confirma só a correção de um achado específico já
  apontado (não a primeira revisão de uma fatia/PR inteiro — ex.: `code-reviewer`/`qa-engineer`/
  `security-engineer` reinvocados depois de uma correção pontual), a verificação independente: (a)
  sempre confirma a correção com evidência direta (leitura do diff no ponto exato, teste
  manual/pontual, ou equivalente) — nunca só a palavra de quem corrigiu; (b) roda pelo menos o
  subconjunto de testes do arquivo/módulo tocado pela correção. A suíte 100% completa do zero só
  precisa rodar de novo **uma vez — na última rodada de verificação antes do merge efetivo da
  fatia** — não em cada rodada intermediária de reverificação pontual.
- [ ] **Investigação de causa raiz somente-leitura prefere uma sub-tarefa isolada a inflar o
  contexto principal.** Quando quem orquestra uma etapa (ex. `/sdd-implement` decidindo o que pedir
  numa correção pontual, ou `/sdd-pending` ajudando a responder um item VALIDAR DEPOIS) precisa ler
  vários arquivos de código, histórico de Git, ou logs só para chegar a uma conclusão — e o
  conteúdo lido não precisa ficar retido depois de decidir o próximo passo — prefira delegar essa
  leitura a uma sub-tarefa isolada que devolva só a conclusão destilada, em vez de fazer a
  investigação diretamente no contexto da sessão que está orquestrando o pipeline. O mecanismo
  concreto (o que o operador do plugin tiver disponível para isolar uma sub-tarefa) não é definido
  por este template — só o princípio de não reter no contexto principal o que só serve para chegar
  à conclusão.
- [ ] **Todo feedback real sobre o próprio plugin vira issue — em qualquer momento de qualquer
  sessão, não só no fim de uma fatia.** Quando o usuário dá um retorno direto sobre o plugin (algo
  que não funcionou como esperado, uma limitação real, uma sugestão concreta) ou você mesmo
  identifica, durante a sessão, um problema real de instrução/comportamento do pipeline — desde
  que generalizável (não específico deste projeto) e acionável (não "poderia ser melhor" genérico)
  — abra uma issue em `asengardeon/btt-sdd-pipeline`: `gh issue create --repo
  asengardeon/btt-sdd-pipeline --title "..." --body "..."`, sempre esse repositório, independente
  de qual projeto está rodando o pipeline agora. Prefixe o título conforme o caso ("Bug:" para
  comportamento incorreto, "Melhoria:" para otimização de fluxo/performance/custo de token,
  "Aprendizado:" para um padrão observado que vale generalizar). Isso **não substitui** a
  retrospectiva garantida ao final de toda fatia aprovada (`.claude/skills/sdd-sre/SKILL.md`,
  seção "Retrospectiva da fatia") — estende a mesma obrigação para qualquer ponto da sessão em que
  o feedback já estiver claro, em vez de represá-lo até aquele checkpoint específico (uma sessão
  que nunca chega a rodar `/sdd-sre` — ex. `/sdd-prd` isolado, uma investigação, um `/repo-issues`
  — não fica sem esse mecanismo só por não ter atingido o fim de uma fatia). Se `gh` falhar (comum
  sem acesso a este repositório específico, ex. plugin instalado por outro operador), relate o
  feedback como texto ao usuário em vez de bloquear o que estava fazendo — mesma tolerância de
  falha do restante do pipeline com `gh` (no máximo 3 tentativas).
- [ ] **Merge de PR nunca é ação de um agente — risco conhecido de agentes autônomos com escrita
  em sistemas compartilhados.** Regra 5 de `CLAUDE.md` ("Fluxo de Git = GitHub Flow") e a linha
  "Merge do PR" de `docs/GIT-WORKFLOW.md` já estabelecem que o merge é decisão do usuário; este
  bullet existe porque, numa sessão real, essa regra em texto livre não foi suficiente — o agente
  `sre`, instruído explicitamente a não mergear (no prompt de invocação e no próprio plano que ele
  mesmo documentou), mergeou um PR sozinho de qualquer forma, ativando uma configuração quebrada
  que causou um outage de produção. Nenhum agente com acesso a `Bash`/`gh` (implementador ou
  revisor de qualquer etapa) executa `gh pr merge` ou equivalente, mesmo que pareça necessário
  para "completar" a tarefa da rodada — isso vale mesmo quando o mesmo agente implementou o ajuste
  que está sendo revisado. A única exceção deliberada e documentada é a skill `/repo-issues`
  (manutenção deste próprio repositório sobre si mesmo), que mergeia os PRs que ela mesma abre só
  depois de aprovação explícita do lote pelo usuário — nunca um padrão a copiar para as etapas do
  pipeline SDD.

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
  Testes-QA), com ID no formato `L-<AAAA-MM-DD>-<slug-curto>` (data da criação da entrada +
  slug curto em kebab-case do próprio achado, ex.: `L-2026-08-25-timeout-http-nao-configuravel`)
  e os campos "Detectado por", "Ocorrências" (caminho do artefato + fatia, por feature), "Padrão
  observado", "Recomendação para implementação" e **"Classe"** (`acionável-por-agente` se o
  próximo dev/agente consegue evitar o padrão sozinho ao implementar a partir da lição; ou
  `depende de ação externa` se a resolução depende de uma configuração fora do código — proteção
  de branch/environment, segredo, permissão de infra — que nenhum agente corrige sozinho sem
  aprovação explícita do usuário). A distinção importa porque a estratégia para quebrar o ciclo de
  repetição é diferente para cada classe (próximo bullet). **Nunca use um contador sequencial simples
  (`L-001`, `L-002`, ...)**: duas branches de fatia diferentes, cada uma calculando o "próximo
  ID" a partir da sua própria cópia local do arquivo, já geraram colisão real de ID em merge —
  exigiu renumeração manual e correção de autorreferências. Data + slug do achado é
  suficientemente único entre branches paralelas sem precisar coordenar um contador global; na
  rara colisão de duas entradas com data e slug idênticos, acrescente um sufixo numérico ao
  segundo (`-2`, `-3`, ...) no momento do merge.
- [ ] `docs/LESSONS-LEARNED.md`, quando criado ou atualizado, é commitado junto do artefato de
  revisão da própria rodada (`code-review.md`/`qa-report.md`/`security-review.md`/
  `sre-review.md`) — nunca num commit separado.
- [ ] **Entrada classificada como `depende de ação externa` que atinge 3 ocorrências confirmadas
  deixa de ser só uma nota passiva.** Ao reconfirmar essa entrada pela 3ª vez (contando a criação
  na 2ª ocorrência), o agente que a reconfirma não só acrescenta a ocorrência à tabela — aciona
  `AskUserQuestion` oferecendo resolver a pendência ali mesmo, se tiver a capacidade técnica para
  isso (ex.: `sre` configurando proteção de branch/environment via API do GitHub —
  `.claude/agents/sre.md`, seção "Áreas de responsabilidade" — sempre sujeito a aprovação
  explícita antes de qualquer mudança real, nunca aplicado sozinho), em vez de silenciar a
  repetição como mais uma linha na tabela. Sem essa capacidade, ainda assim escala explicitamente
  ao usuário. Uma lição sobre configuração externa nunca se resolve sozinha só por ser lida no
  planejamento (diferente de uma entrada `acionável-por-agente`, onde "virar entrada e ser lida no
  planejamento" já quebra o ciclo como desenhado) — já aconteceu de uma entrada ser reconfirmada 17
  vezes em 9 features sem nunca resultar em correção efetiva da configuração.
- [ ] `backend-developer`/`frontend-developer` leem `docs/LESSONS-LEARNED.md`, se existir, na fase
  de planejamento (antes de quebrar o TRD em incrementos) e aplicam as lições da(s) área(s)
  relevante(s) à trilha como restrição adicional ao TRD, citando no plano apresentado ao usuário
  qual lição foi aplicada e como.
- [ ] **Uma entrada de lições aprendidas nunca substitui a regra canônica que ela generaliza.**
  Uma entrada existe para resumir um padrão de achado já repetido, não para redefinir a regra
  original — se a entrada (ou a paráfrase de qualquer agente ao aplicá-la) parecer contradizer ou
  ser mais estreita que uma regra já formalizada em outro doc do projeto (`docs/TESTING.md`,
  `docs/QUALITY-GATES.md`, etc.), a regra canônica prevalece: releia a doc de origem antes de
  tratar a lição como atalho, e sinalize a divergência como um sinal de que a própria entrada
  precisa de correção, não de que a regra mudou. Já aconteceu: uma lição registrada como "sempre
  que X tocar Y" restringiu implicitamente uma regra original incondicional ("toda fatia com
  trilha Z"), e `frontend-developer` pulou uma etapa obrigatória (build real) a partir da versão
  estreita — só pego porque duas rodadas de revisão independentes checaram a regra original em vez
  de confiar na paráfrase.

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
- [ ] **Caso especial: a última fatia de uma spec nunca tem "fatia seguinte" para disparar a regra
  acima.** A promoção para `concluído (mergeado)` fica presa em `aprovado` para sempre se nada mais
  a confirmar — `/sdd-implement`, passo 2a, cobre isso: ao ser invocado sem nenhuma fatia pendente,
  confirma o merge real da última fatia (`gh pr view <N> --json state,mergedAt`) e promove o Status
  retroativamente se ainda não tiver sido feito, antes de simplesmente informar "nada a fazer". Já
  causou um falso-positivo sistemático em 7 specs de um mesmo projeto — todas 100% mergeadas,
  reportadas como "próxima fatia pendente" indefinidamente por `/sdd-status`/`/sdd-pending`.
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
- [ ] Se a feature tem UI, o usuário foi consultado (via `AskUserQuestion`, `/sdd-prd` passo 2b)
  sobre ver opções de wireframe/protótipo antes do PRD — aceite ou recusa, nunca silenciado; seção
  "Wireframes/Protótipos de tela" preenchida de acordo (ou "não aplicável" se a feature não tem UI).
  Se opções foram geradas, o(s) arquivo(s)-fonte `.dc.html` estão salvos em
  `specs/<slug>/wireframes/` (não só a URL do Artifact) — para conferência futura mesmo se o
  Artifact publicado não estiver mais acessível. Se `docs/DESIGN-SYSTEM.md` ainda não existir neste
  projeto, o usuário foi consultado sobre estabelecer um antes de gerar as opções (aceite ou
  recusa, nunca silenciado) — campo "Sistema de design usado" preenchido de acordo.
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
- [ ] **Toda tarefa tem a coluna "Issue GitHub" preenchida — obrigatório, não mais opcional.** Se
  não há remote GitHub configurado/autenticado, o TRD não pode ser aprovado ainda (`architect`
  para e pede para configurar `git remote`/`gh auth login` primeiro); só o PRD dispensa GitHub.
- [ ] **Toda issue GitHub que o pipeline cria no repositório do projeto-alvo carrega identificação
  estruturada da spec de origem** — não só as de tarefa do TRD. `architect` já garante isso para as
  issues de tarefa via o milestone por spec (acima). Reaproveite esse mesmo milestone (mesmo
  `<slug>`) sempre que outra issue do pipeline se referir à mesma spec/projeto — ex.: a issue de
  `/sdd-hotfix` (`.claude/skills/sdd-hotfix/SKILL.md`, passo 1b) quando o bug tem spec relacionada.
  Se ainda não existir nenhum milestone para essa spec (spec sem decomposição de tarefas em issues),
  aplique em vez disso um label `spec:<slug>` (criando-o se faltar). Uma issue aberta sem nenhuma
  spec relacionada (melhoria pontual sem origem) não precisa dessa identificação.
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
- [ ] **Antes de criar a branch, `/sdd-implement` confirmou que toda tarefa desta fatia tem a
  coluna "Issue GitHub" preenchida no TRD — nenhuma fatia começa sem isso** (gate obrigatório,
  `.claude/skills/sdd-implement/SKILL.md`, passo 2c-ter). O mesmo vale para `/sdd-hotfix`: a issue
  do bug/ajuste existe antes da branch ser criada. Antes de tratar uma coluna "Issue GitHub" vazia
  como fatia pendente, o mesmo gate cruza com `git log`/`gh pr list` em busca de um commit/PR já
  mergeado cobrindo aquela fatia — Status desatualizado no TRD é uma discrepância de documentação
  a corrigir, não trabalho pendente a reabrir com issues novas.
- [ ] Branch da fatia criada a partir de `main` atualizada (só depois do PR da fatia anterior já
  mergeado, se houver uma); PR aberto (única branch/PR por fatia, mesmo quando backend e frontend
  desenvolvem em paralelo dentro dela).
- [ ] O PR referencia `Closes #N` para cada issue do GitHub associada às tarefas desta fatia
  (coluna "Issue GitHub" do TRD) — issues ficam abertas até o merge de verdade, nunca fechadas
  manualmente antes disso.
- [ ] Plano de implementação foi aprovado pelo usuário antes do primeiro commit de código (plano
  combinado quando full-stack, orquestrado por `/sdd-implement`).
- [ ] Resultado da suíte completa com cobertura gravado em
  `specs/<slug>/coverage/<fatia>-<trilha>.md` (`docs/TESTING.md`), com o commit SHA da execução —
  formato condensado, nunca o relatório bruto (HTML) colado — para as etapas seguintes
  reaproveitarem em vez de re-executar a suíte.
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  também rodou e passou, registrado no mesmo arquivo de cobertura (`docs/TESTING.md`, seção
  "Build/empacotamento real como parte da suíte completa") — lint/tipo/teste unitário sozinhos não
  bastam como "suíte completa" nesse caso.

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
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  foi verificado (reaproveitado do arquivo de cobertura da fatia ou reexecutado nesta rodada) antes
  de aprovar — nunca aprovado só com base em lint/tipo/teste unitário nesse caso
  (`docs/TESTING.md`, seção "Build/empacotamento real como parte da suíte completa").
- [ ] `code-review.md` existe, referencia o PR e a fatia desta rodada, e cada área de revisão tem
  veredito com evidência (arquivo/linha) ou "sem achados".
- [ ] `code-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `code-reviewer` antes de devolver o resultado.

## QA

- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) —
  sem isso, o QA não começa.
- [ ] Cobertura medida e comparada ao gate de 80% — sem relatório de cobertura confiável, não há
  aprovação possível.
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  foi verificado antes de aprovar — lint/tipo/teste unitário sozinhos não são "suíte completa"
  nesse caso (`docs/TESTING.md`, seção "Build/empacotamento real como parte da suíte completa").
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

- [ ] **Critério objetivo para segurança obrigatória, mesmo numa correção pontual pequena** (fora
  do fluxo normal de fatia — ex. `/sdd-hotfix`, `docs/POST-MERGE-VALIDATION.md`, ou qualquer ajuste
  que o orquestrador considerou "pequeno demais" para o pipeline completo): `security-engineer`
  roda sempre que o diff tocar **qualquer um** dos itens abaixo, independente do tamanho da
  mudança — nunca uma decisão de "merece ou não" reavaliada caso a caso pelo orquestrador:
  - Autenticação (login, criação/validação de sessão, emissão/verificação de token/credencial).
  - Autorização (checagem de permissão/papel, controle de acesso a recurso).
  - Gestão de sessão (criação, expiração, invalidação, armazenamento de sessão).
  - Dados pessoais/sensíveis (PII, credencial, dado financeiro/saúde, qualquer campo que já exija
    tratamento especial em `security-review.md` de outra feature).
  - Qualquer ponto de entrada que aceita um identificador externo (e-mail, identidade de SSO,
    token, ID de usuário de terceiro) vindo de fora do sistema.
  Fora desses casos, a decisão de acionar segurança numa correção pontual pequena continua a
  critério do orquestrador (mas registrada, nunca implícita).
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
- [ ] `ci.yml` tem filtro de `paths`/`paths-ignore` cobrindo `specs/**`, `docs/**` e `*.md` da raiz
  — push/PR que só toca esses caminhos pula lint/testes/build (nenhum código executável mudou,
  zero risco de qualidade). Sem esse filtro, cada push de um artefato de revisão
  (`code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md`) dispara um run completo
  desnecessário (`.claude/agents/sre.md`, área "CI").
- [ ] `main` protegida: sem push direto, PR obrigatório, status checks obrigatórios (verificado,
  não necessariamente configurado pelo agente — configuração real é do administrador do repo).
- [ ] Deploy só roda após CI verde.
- [ ] Se a fatia torna obrigatório um campo antes opcional/ausente numa rota já ativa consumida
  por um cliente já implantado que ainda não foi atualizado para enviá-lo, e os gates de deploy
  automático relevantes já estão ligados: bloqueante até haver um default retrocompatível nesta
  fatia, ou confirmação explícita do usuário aceitando a janela de quebra em produção — nunca uma
  nota não-bloqueante de coordenação de deploy (`.claude/agents/sre.md`, área "CD e GitHub Flow").
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
- [ ] **Retrospectiva da fatia conduzida — em toda fatia aprovada, não só a última.** `/sdd-sre`
  (`.claude/skills/sdd-sre/SKILL.md`, passo 5c) avalia a execução da rodada e abre issues de
  melhoria/aprendizado em `asengardeon/btt-sdd-pipeline` **antes** de informar o resultado ao
  usuário (passo 6) — nunca depois, e nunca pulado só porque a fatia já foi aprovada. "Nenhuma
  sugestão/aprendizado concreto desta fatia" é uma conclusão válida do passo; "não avaliei" não é.
- [ ] Se esta é a **última fatia pendente** da feature (spec finalizada): `tech-writer` foi
  acionado para atualizar a documentação (`/sdd-sre`, passo 5b) **e** o teste geral obrigatório de
  fim de spec contra produção real foi conduzido depois do merge
  (`docs/POST-MERGE-VALIDATION.md`, seção "Teste geral obrigatório ao finalizar uma spec") — a
  spec só é considerada de fato concluída com os dois.
