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
  escreve veredito em `code-review.md`/`ux-review.md`/`qa-report.md`/`security-review.md`/
  `sre-review.md` na
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
- [ ] **Reconfirmar um ponto técnico já documentado em detalhe por uma etapa anterior não exige
  reescrever a explicação inteira.** Quando `code-review.md`/`qa-report.md`/`security-review.md`
  já documentou em detalhe um mecanismo específico (ex.: uma mitigação de IDOR, uma ordem de
  validação) com veredito "sem achado", a etapa seguinte (`qa-engineer`/`security-engineer`/`sre`)
  continua obrigada a reconfirmar esse ponto com sua própria verificação independente (ler o teste
  relevante, rodar o cenário) — isso não relaxa o bullet "Nenhum agente aprova/reprova o próprio
  trabalho" nem o gate de verificação independente. Muda só como a conclusão é **registrada**: uma
  linha referenciando o relatório anterior (ex.: "mitigação de IDOR reconfirmada independentemente
  via teste X — mecanismo em `code-review.md`, seção N") em vez de reescrever a narrativa completa
  do zero. Reduz tamanho de artefato e custo de geração (tempo e tokens) sem reduzir o rigor da
  verificação.
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
- [ ] **Instrução de processo permanente que o usuário emite no meio de uma execução é registrada em
  `docs/PROJECT-CONVENTIONS.md` na mesma hora — não repassada no prompt de cada agente seguinte.**
  Distinga da decisão pontual sobre esta fatia (essa vive no artefato da etapa): é permanente quando
  vale para as fatias e specs seguintes deste projeto ("aqui não se roda teste de mutação por
  fatia", "aqui o gate de cobertura é 70%", "aqui e2e roda só no CI", "aqui não existe `infra/`").
  Nesse caso, o orquestrador acrescenta uma linha datada a `docs/PROJECT-CONVENTIONS.md` — criando o
  arquivo se não existir — em vez de repetir a frase no prompt de cada agente. O canal do prompt é o
  mais caro (repetido a cada invocação) e o mais frágil (desaparece quando alguém esquece, ou quando
  a sessão muda). Já aconteceu de verdade: uma regra de processo emitida no meio de uma fatia foi
  repassada manualmente **quatro vezes** (implementação, revisão de código, QA, segurança), e cada
  agente a transcreveu no relatório como "instrução explícita do usuário nesta rodada" — a marca de
  algo que chegou por prompt e não por documento, sem garantia nenhuma de chegar à fatia seguinte.
  Todos os agentes do pipeline leem esse arquivo como restrição que se sobrepõe ao padrão genérico
  (`.claude/agents/*.md`, bloco de leitura obrigatória no topo), então uma linha ali substitui os quatro
  repasses — e o agente passa a poder escrever "fora do escopo por `docs/PROJECT-CONVENTIONS.md`" em
  vez de "por instrução do usuário nesta rodada": a diferença entre uma regra auditável e um boato
  repassado.
- [ ] **Pergunta que um subagente isolado não conseguiu fazer é recolhida por quem o invocou, no
  mesmo turno — não vira pendência.** Um agente rodando isolado/assíncrono não tem
  `AskUserQuestion`; registrar a pergunta como "VALIDAR DEPOIS" no próprio relatório é o fallback
  **correto dele**, que não tinha a ferramenta. Não é o fallback de quem orquestra, que tem — e o
  usuário está disponível justamente no turno em que a etapa roda. **O orquestrador de qualquer
  etapa** (implementação, revisão de código, UX, QA, segurança, SRE) apresenta essas perguntas via
  sua própria `AskUserQuestion` antes de informar o resultado da etapa, e devolve ao relatório as
  que o usuário responder — como decisão registrada, não como pendência. As que ele não souber
  responder agora continuam VALIDAR DEPOIS, aí legitimamente. Já aconteceu de perguntas binárias de
  política e de comportamento — respondíveis em segundos — atravessarem QA e segurança inteiros
  como dívida, porque só `sre` e os agentes de implementação tinham esse passo escrito.
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
- [ ] **Comando de build/teste que o próprio agente precisa aguardar antes de decidir o próximo
  passo sempre roda em primeiro plano, bloqueando o turno até o resultado — nunca em background.**
  O harness considera o turno de um subagente "concluído" assim que ele para de emitir chamadas de
  ferramenta, mesmo que um processo real de build/teste ainda esteja rodando no sistema
  operacional em background, fora do rastreamento que dispara notificação automática. Já aconteceu
  de verdade: um `backend-developer` disparou `dotnet test`/`dotnet build` em background e encerrou
  o próprio turno sem aguardar, duas vezes seguidas — o orquestrador recebeu "tarefa concluída"
  quando na verdade era só o agente dizendo que ia esperar, sem ter esperado, e precisou monitorar
  processos do sistema operacional manualmente para descobrir quando os testes de fato terminavam.
  Vale para todo agente de implementação ou revisão deste pipeline (`backend-developer`,
  `frontend-developer`, `code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`)
  sempre que o
  comando decide o próximo passo da própria invocação — não é um caso a avaliar por demora
  esperada, mesmo um comando historicamente lento roda em primeiro plano até o fim.
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
- [ ] **Métrica de ambiente citada numa entrada vale só para a ocorrência que a mediu — quem
  registra uma ocorrência nova remede e reatribui, nunca copia da anterior.** Quando a assinatura
  ou a causa de uma entrada cita um número de ambiente ("N processos concorrentes de outros
  worktrees", "memória livre abaixo de X", "fila do runner acima de Y"), **remedir é parte de
  registrar a ocorrência**. Para métricas de processo/recurso, medir significa responder duas
  perguntas que o número de manchete não responde: quantos dos processos contados são realmente o
  que se supõe (processo real vs. processo filho), e **desde quando existem**. Repetir a métrica
  sem remedir registra **correlação, não causa** — e cada nova ocorrência que a copia faz a
  explicação *parecer* mais confirmada quando só está sendo propagada. Já aconteceu de verdade: uma
  entrada de flakiness de suíte de integração chegou à **18ª ocorrência** carregando "71
  `chrome.exe` + 7 `dotnet.exe` concorrentes de outros worktrees" como causa ambiental; medido sob
  exatamente os mesmos números de manchete, só **2** dos 71 eram navegadores (os outros 69, processos
  filhos), **60** pertenciam ao navegador pessoal do operador aberto 4 dias antes da spec começar, e
  6 dos 7 `dotnet.exe` eram nós ociosos de reuso do build. A flakiness era real; a explicação
  causal não — e a conduta que ela induzia ("esperar a contenção baixar") nunca poderia convergir,
  porque o número quase não desce.
- [ ] **A recíproca: entrada cuja métrica se mostra mal atribuída tem a prosa corrigida, não só a
  contagem incrementada.** Uma entrada acumula autoridade junto com ocorrências — corrigir o texto
  da causa é o que impede que as ocorrências seguintes continuem herdando a explicação errada. Vale
  para o "Padrão observado" e para a "Recomendação para implementação", não só para a tabela de
  ocorrências.
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
  planejamento — já aconteceu de uma entrada ser reconfirmada 17 vezes em 9 features sem nunca
  resultar em correção efetiva da configuração.
- [ ] **Entrada classificada como `acionável-por-agente` que atinge 3 ocorrências confirmadas sem
  correção efetiva também escala — não é exclusividade de `depende de ação externa`.** "Virar
  entrada e ser lida no planejamento" evita o bug em código *novo*, mas não corrige consumidores já
  existentes com o mesmo padrão que nenhuma sessão foi tocar de propósito — uma lição pode ser lida
  e aplicada corretamente em toda feature nova e, mesmo assim, o padrão continuar presente
  indefinidamente em código antigo nunca revisitado. Ao reconfirmar essa entrada pela 3ª vez, o
  agente de revisão que a reconfirma (`code-reviewer`/`qa-engineer`/`security-engineer`/`sre`, o
  que estiver rodando) propõe explicitamente, via `AskUserQuestion` (ou repassando a pergunta ao
  orquestrador se estiver rodando em background), uma mini-fatia/hotfix dedicada para aplicar a
  correção já conhecida a todos os consumidores afetados — mesmo que a correção em si fique fora do
  escopo da fatia atual, a proposta explícita ao usuário não fica. Já aconteceu de verdade: uma
  correção conhecida e testada desde a 1ª ocorrência (trocar um método de resolução de identidade
  tenant-escopado por uma variante entre tenants) nunca foi propagada aos demais consumidores, e a
  mesma entrada chegou à 3ª ocorrência com o próprio achado já recomendando prioridade em texto
  livre — sem nada no processo formal forçando essa priorização a acontecer.
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
- [ ] `code-reviewer`/`ux-designer`/`qa-engineer`/`security-engineer`/`sre` atualizam para
  `bloqueado` (com o motivo em uma linha) as tarefas da fatia cujo veredito desta rodada foi
  reprovado.
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
- [ ] **Se a feature tem alteração de UI de verdade** (mesmo gate do bullet acima), `ux-designer`
  foi acionado em modo consultoria (`.claude/agents/ux-designer.md`, seção "Pré-condição (modo
  consultoria de PRD)") — independente de o usuário ter topado ver wireframes ou não — e a
  subseção "Parecer de UX" do PRD está preenchida com o parecer recebido, "sem observações
  relevantes", ou "não aplicável" só quando a feature genuinamente não tem UI. Esse parecer é
  informativo, nunca um veredito — não é gate de aprovação em si, só precisa estar registrado.
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
- [ ] **Todo seletor/locator/contrato concreto contra um sistema externo cuja estrutura real não foi
  observada está marcado como provisório no próprio texto onde aparece, e tem uma tarefa de
  investigação agendada como primeira tarefa da primeira fatia que depende dele** — nunca só uma
  pendência "VALIDAR DEPOIS", que não bloqueia nada. Vale para seletor de DOM de terceiro, formato de
  resposta de API não documentada, layout de arquivo de parceiro, esquema de webhook, nome de campo
  de SSO. O motivo é que nenhuma etapa posterior pega esse erro: o dublê escrito a partir da suposição
  valida a suposição, e a suíte fica verde contra ela — code review, UX, QA, segurança e SRE revisam
  o código contra o TRD, e aqui o TRD é a fonte do erro. Já aconteceu de um locator desenhado casar
  zero elementos no DOM real por um defeito do próprio site de terceiro, pego só porque a tarefa de
  investigação existia (`.claude/agents/architect.md`, passo 1c).
- [ ] **Na seção "Riscos e trade-offs", toda afirmação sobre comportamento concreto de biblioteca
  de terceiro ou de runtime está marcada `[medido]` (com versão e como) ou `[não medido]`**, e toda
  alegação de contenção ("vira falha daquela linha") cita o ponto do código onde a contenção
  acontece. Afirmação desse tipo sem marcação é lida como fato estabelecido e atravessa o pipeline
  inteiro sem verificação — inclusive escrita com hedge ("em teoria", "lançaria"), que faz o texto
  parecer análise prudente.
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
  (coluna "Issue GitHub" do TRD), **com a palavra-chave repetida por issue** (`Closes #117, Closes
  #118`), nunca a lista com vírgulas simples (`Closes #117, #118`), que o GitHub aplica só ao
  primeiro número (`docs/GIT-WORKFLOW.md`, regra 5b) — issues ficam abertas até o merge de verdade,
  nunca fechadas manualmente antes disso.
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
- [ ] **Fatia que estende um guard/regra de autorização já implementado por uma fatia anterior
  (ex.: de "só autor" para "autor OU organizador/admin") renomeia os testes cujo nome descreve o
  comportamento que a nova fatia inverte — não só altera a asserção.** Um teste chamado
  `test_rejects_organizer` cuja asserção passou a esperar sucesso em vez de recusa é uma inversão
  semântica silenciosa: o nome descreve um comportamento que já não é mais verdade. Confirme
  também, via grep pelo nome antigo do teste no restante da suíte, que nenhuma referência órfã
  (import, chamada direta, menção em comentário) ficou para trás. Achado bloqueante se algum teste
  tocado pela fatia mantiver um nome que descreve o comportamento anterior.
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  foi verificado (reaproveitado do arquivo de cobertura da fatia ou reexecutado nesta rodada) antes
  de aprovar — nunca aprovado só com base em lint/tipo/teste unitário nesse caso
  (`docs/TESTING.md`, seção "Build/empacotamento real como parte da suíte completa").
- [ ] Se o TRD marca esta fatia como portadora de uma quebra de contrato (seção "Janelas de quebra
  de contrato entre fatias", coluna "`!` no título do PR"), o título do PR tem `!` antes dos
  dois-pontos (ou o rodapé `BREAKING CHANGE:` no corpo) — checagem de um caractere, três etapas
  antes do SRE (`docs/GIT-WORKFLOW.md`, seção "Quebra de contrato e o título do PR"). Uma quebra
  encontrada no diff que o TRD **não** declarou é achado por si só.
- [ ] `code-review.md` existe, referencia o PR e a fatia desta rodada, e cada área de revisão tem
  veredito com evidência (arquivo/linha) ou "sem achados".
- [ ] `code-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `code-reviewer` antes de devolver o resultado.

**Nota sobre o custo de CI desta exigência** (vale igualmente para `ux-review.md`, `qa-report.md`,
`security-review.md`, `sre-review.md`, `timing-log.md` e as rodadas de correção): como cada etapa
commita e envia seu artefato na branch da fatia, **depois que o código para de mudar a branch ainda
recebe uma dezena de commits de documentação pura**, cada um disparando o CI completo no PR. Isso é
consequência estrutural do pipeline, não descuido — e é por isso que existe a receita de
short-circuit de docs-only na seção "SRE / CI-CD / Infra" abaixo. Não resolva isso deixando de
commitar o artefato: o artefato na branch é o que torna a revisão auditável.

## UX / Usabilidade (`ux-designer`, condicional)

- [ ] **Critério objetivo para UX review obrigatória**: sempre que o diff da fatia tocar alguma
  tela/fluxo com superfície de UI perceptível pelo usuário final (layout, navegação, visibilidade
  condicional de controles, estado vazio/erro, conteúdo de mídia) — nunca uma decisão de "merece
  ou não" reavaliada caso a caso. Fatia 100% backend/infra sem nenhuma tela afetada marca a etapa
  como "não aplicável", registrado em `ux-review.md` sob o heading padronizado `## Decisão: UX
  review pulado (justificado)`, nunca simplesmente omitida.
- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) —
  sem isso, a UX review não começa.
- [ ] Cada uma das 7 áreas de revisão (consistência e padrões; visibilidade do estado do sistema e
  prevenção de erro; controle/liberdade do usuário e navegabilidade; consciência de estado/ciclo
  de vida do domínio; robustez de conteúdo gerado pelo usuário; hierarquia de informação; alvo de
  toque/acessibilidade básica) tem veredito com evidência ou "sem achados" — nunca em branco.
- [ ] O método usado nesta rodada (verificação ao vivo via automação de navegador, ou leitura de
  código na ausência dela) está documentado em `ux-review.md` — um veredito baseado só em leitura
  estática nunca é apresentado como equivalente a uma verificação ao vivo.
- [ ] `ux-review.md` referencia o PR e a fatia desta rodada.
- [ ] `ux-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `ux-designer` antes de devolver o resultado.

## QA

- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) —
  sem isso, o QA não começa.
- [ ] Se a fatia tem superfície de UI perceptível (UX review não marcada "não aplicável"),
  `ux-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) — sem
  isso, o QA não começa.
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
- [ ] **Cadência de CI conferida contra `docs/PROJECT-CONVENTIONS.md`.** Padrão (arquivo ausente
  ou sem essa seção): suíte completa a cada push. Se o projeto registra `ci-antes-do-merge`, o
  `ci.yml` roda a suíte completa quando o PR **não é draft** (e em push para a branch base) e
  reporta sucesso em segundos enquanto o PR é draft — com o gate nos **passos**, nunca no job nem no
  gatilho, senão o *required status check* nunca reporta e o PR fica bloqueado para sempre (mesma
  armadilha do `paths-ignore`). O `sre` nunca adota essa cadência por conta própria: ela é opt-in do
  projeto (`agents/sre.md`, área "CI").
- [ ] `ci.yml` pula lint/testes/build numa mudança só de documentação **comparando `HEAD` com o último run verde desta branch** — nunca por `paths`/`paths-ignore` no gatilho, que deixa um PR
  só de documentação bloqueado para sempre quando o job é *required status check* (o workflow não
  dispara, o GitHub nunca reporta status), nem por diff contra o tip de `main`, que num PR de código
  sempre acusa `src/` e por isso nunca dispara o short-circuit. Receita completa e a medição que a
  justifica em `.claude/agents/sre.md`, área "CI". Falha em qualquer etapa da checagem → roda a
  suíte (direção de falha segura).
- [ ] Se este projeto tem hoje `paths`/`paths-ignore` no gatilho de um check obrigatório, isso é
  reportado como achado — é a forma que #146 pediu e que a medição depois mostrou ser errada, não
  uma configuração a preservar.
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

- [ ] PR desta fatia aberto, CI verde, revisão de código aprovada, revisão de UX aprovada (ou
  marcada "não aplicável" quando a fatia não tem superfície de UI), QA aprovado, segurança
  aprovada, SRE aprovado (ou aprovado com ressalvas não-bloqueantes explicitamente aceitas pelo
  usuário em qualquer uma dessas etapas) — tudo escopado a esta fatia, não à feature inteira.
- [ ] **Depois do merge, todas as issues da fatia foram confirmadas fechadas** (`gh pr view <PR>
  --json closingIssuesReferences`), e as que não fecharam sozinhas foram fechadas à mão citando o
  PR. Não basta o corpo do PR *parecer* correto: `Closes #A, #B, #C` fecha só a primeira em
  silêncio — a forma válida repete a palavra-chave (`docs/GIT-WORKFLOW.md`, regras 5b e 5c).
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
