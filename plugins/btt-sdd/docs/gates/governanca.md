# Governança de decisão (vale para todas as etapas, incluindo a condicional de baseline)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] **Nenhuma suposição não documentada.** Toda ambiguidade que mudaria o artefato (requisito,
  decisão técnica, interpretação de critério de aceite, decisão de infraestrutura) vira uma pergunta
  explícita ao usuário — nunca uma escolha silenciosa do agente.
- [ ] **"VALIDAR DEPOIS" é sempre uma opção válida.** Quando o usuário não sabe responder agora, o
  agente registra o item na seção "Pendências de validação (VALIDAR DEPOIS)" do artefato, com
  contexto suficiente para retomar sem re-explicar tudo. O item some da lista de pendências só
  quando resolvido via `/btt-sdd:amend` (ver `docs/SDD-WORKFLOW.md`).
- [ ] **Nenhuma ação ou requisição se repete mais de 3 vezes.** Tentativas de corrigir o mesmo
  teste, rodar o mesmo comando, ou reformular a mesma pergunta contam como a mesma ação. Na 3ª falha
  consecutiva, o agente para e escala ao usuário: o que foi tentado, por que falhou, e o que ele
  recomenda como próximo passo. Isso vale tanto para ações técnicas (fix de teste, `apply` de
  infraestrutura) quanto para tentativas de obter uma resposta clara do usuário.
- [ ] **Todo plano de ação real (código, infraestrutura) é aprovado antes de executar.** PRD e TRD
  já são planos por natureza — sua aprovação é o próprio gate. Para `/btt-sdd:implement` e
  `/btt-sdd:sre`, o agente apresenta o plano (incrementos, branch, ou mudança de infra proposta) e
  obtém aprovação explícita do usuário antes de escrever código ou tocar infraestrutura real.
- [ ] **Artefatos aprovados são editados in-place, nunca recriados do zero.** Mudar uma decisão já
  aprovada usa `/btt-sdd:amend`, que registra a mudança no "Log de revisões" e só reabre as etapas
  posteriores realmente afetadas — etapas anteriores aprovadas continuam válidas.
- [ ] **Corrigir uma frase de mecanismo exige duas perguntas antes de fechar o achado.** Prosa que
  descreve *como* uma garantia é obtida continua sendo lida como verdade depois que o *como* mudou —
  e o pipeline reescreve o *como* a cada rodada de correção, então qualquer projeto com mais de uma
  rodada de revisão por fatia produz isso. Ao reescrever uma frase dessa classe (num PRD, TRD, ADR,
  docstring, docblock ou relatório de revisão), responda explicitamente:
  - **"Quantas enumerações esta frase tem?"** Uma linha de plano de testes costuma ter **duas** — *o
    que* é coberto e *quais propriedades* são asseveradas. Trocar uma e deixar a outra **move** o
    defeito em vez de eliminá-lo, e o movimento é invisível porque a frase agora *parece* corrigida.
    Já aconteceu de verdade: a contagem foi trocada por critério ("nos 6 estados" → "toda
    renderização visível"), a reescrita estava certa, e o defeito seguinte entrou pelo segundo eixo —
    duas mutações sobreviveram à suíte inteira (1644/1644 verdes), e uma terceira propriedade nem
    constava do relatório.
  - **"Em quantos lugares este mesmo mecanismo está descrito?"** Rode `grep` pela afirmação antiga
    antes de fechar o achado, e substitua cada reaparição por referência ao lugar canônico em vez de
    repetir a frase. Já aconteceu de um mecanismo estar descrito em **quatro** lugares (port no TRD,
    docstring do port, docblock do provider, docblock da cópia) mais a célula de critério de outra
    seção, e a correção acertar três — um `grep` acha o que nenhuma revisão de prosa acha.
- [ ] **Nenhum agente encerra numa branch de feature.** Todo agente que faz `git checkout`/ `git
  switch` para uma branch de fatia (implementadores e revisores que commitam achados na branch do
  PR) confirma a branch atual (`git branch --show-current`) antes de finalizar e, se não for a
  branch base a partir da qual a branch da fatia foi criada (normalmente `main`), volta para ela
  (`git checkout <branch base>`). Já causou dano real deixar o working directory na branch errada
  (ex.: um `git pull origin main` rodado sem perceber a branch atual gerou um merge commit espúrio).
- [ ] **Nenhum veredito agregado fica verde com uma sub-condição falhando.** Vale para item de
  checklist que agrega várias verificações (ex.: "proteção de `main` configurada", que reúne PR
  obrigatório, checks obrigatórios, `strict`, sem force-push, sem deleção, `enforce_admins`) e para
  o veredito de uma "área de revisão" que agrega vários achados. Ou o item vira ⚠️ e a
  sub-condição que falha entra como **achado**, ou cada sub-condição ganha a própria linha.
  Descrever a exceção em prosa ao lado de um ✅ é exatamente o modo de falha a evitar: **quem lê o
  checklist não lê a prosa**, e a exceção atravessa rodadas. Já aconteceu de verdade: uma
  sub-condição de proteção de branch desligada foi reportada como *estado*, dentro do parágrafo de
  evidência de um item marcado ✅, em **7 ocorrências ao longo de 6 specs do mesmo projeto**, sempre
  no mesmo item, e nunca como achado. O custo não é teórico — aquela sub-condição era a única
  camada do pipeline que não depende de um agente obedecer.
- [ ] **Nenhum agente aprova/reprova o próprio trabalho.** Um agente implementador
  (`backend-developer`/`frontend-developer`, ou `sre` fazendo um ajuste pontual de infra) nunca
  escreve veredito em `code-review.md`/`ux-review.md`/`qa-report.md`/`security-review.md`/
  `sre-review.md` na mesma rodada em que implementou a correção — mesmo sendo tecnicamente o mesmo
  tipo de agente que normalmente revisaria aquilo. O gate exige uma instância nova e independente do
  agente de revisão correspondente, invocada depois.
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
  reescrever a explicação inteira.** Quando `code-review.md`/`qa-report.md`/`security-review.md` já
  documentou em detalhe um mecanismo específico (ex.: uma mitigação de IDOR, uma ordem de validação)
  com veredito "sem achado", a etapa seguinte (`qa-engineer`/`security-engineer`/`sre`) continua
  obrigada a reconfirmar esse ponto com sua própria verificação independente (ler o teste relevante,
  rodar o cenário) — isso não relaxa o bullet "Nenhum agente aprova/reprova o próprio trabalho" nem
  o gate de verificação independente. Muda só como a conclusão é **registrada**: uma linha
  referenciando o relatório anterior (ex.: "mitigação de IDOR reconfirmada independentemente via
  teste X — mecanismo em `code-review.md`, seção N") em vez de reescrever a narrativa completa do
  zero. Reduz tamanho de artefato e custo de geração (tempo e tokens) sem reduzir o rigor da
  verificação.
- [ ] **Investigação de causa raiz somente-leitura prefere uma sub-tarefa isolada a inflar o
  contexto principal.** Quando quem orquestra uma etapa (ex. `/btt-sdd:implement` decidindo o que
  pedir numa correção pontual, ou `/btt-sdd:pending` ajudando a responder um item VALIDAR DEPOIS)
  precisa ler vários arquivos de código, histórico de Git, ou logs só para chegar a uma conclusão —
  e o conteúdo lido não precisa ficar retido depois de decidir o próximo passo — prefira delegar
  essa leitura a uma sub-tarefa isolada que devolva só a conclusão destilada, em vez de fazer a
  investigação diretamente no contexto da sessão que está orquestrando o pipeline. O mecanismo
  concreto (o que o operador do plugin tiver disponível para isolar uma sub-tarefa) não é definido
  por este template — só o princípio de não reter no contexto principal o que só serve para chegar à
  conclusão.
- [ ] **Sub-tarefa auxiliar de trabalho bem definido roda em tier econômico; etapa com veredito,
  nunca.** As duas coisas que este pipeline invoca como subagente têm perfis de custo opostos
  (`docs/MODEL-TIERING.md`): a sub-tarefa isolada do bullet acima tem formato de saída definido
  antes da invocação e resultado conferível sem refazer o trabalho — rebaixar o modelo dela erra
  barato, no mesmo turno, para quem pode reinvocar. Já qualquer etapa do pipeline — inclusive as
  condicionais — escreve artefato aprovável e decide gate: ali o modelo é **sempre o padrão da
  sessão**, porque o
  risco de um gate aprovado indevidamente não é pago por quem economizou, e sim por quem lê o
  artefato três etapas adiante. O teste das cinco condições, os limites rígidos (nunca pelo
  frontmatter do agente, nunca em correção de achado, uma única repromoção) e o registro na coluna
  `Modelo` do `timing-log.md` estão em `docs/MODEL-TIERING.md` — e a dúvida sempre resolve para o
  modelo mais capaz, nunca para o mais barato.
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
  (`agents/*.md`, bloco de leitura obrigatória no topo), então uma linha ali substitui os quatro
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
  identifica, durante a sessão, um problema real de instrução/comportamento do pipeline — desde que
  generalizável (não específico deste projeto) e acionável (não "poderia ser melhor" genérico) —
  abra uma issue em `asengardeon/btt-sdd-pipeline`: `gh issue create --repo
  asengardeon/btt-sdd-pipeline --title "..." --body "..."`, sempre esse repositório, independente de
  qual projeto está rodando o pipeline agora. Prefixe o título conforme o caso ("Bug:" para
  comportamento incorreto, "Melhoria:" para otimização de fluxo/performance/custo de token,
  "Aprendizado:" para um padrão observado que vale generalizar). Isso **não substitui** a
  retrospectiva garantida ao final de toda fatia aprovada (`skills/sre/SKILL.md`, seção
  "Retrospectiva da fatia") — estende a mesma obrigação para qualquer ponto da sessão em que o
  feedback já estiver claro, em vez de represá-lo até aquele checkpoint específico (uma sessão que
  nunca chega a rodar `/btt-sdd:sre` — ex. `/btt-sdd:prd` isolado, uma investigação, um
  `/repo-issues` — não fica sem esse mecanismo só por não ter atingido o fim de uma fatia). Se `gh`
  falhar (comum sem acesso a este repositório específico, ex. plugin instalado por outro operador),
  relate o feedback como texto ao usuário em vez de bloquear o que estava fazendo — mesma tolerância
  de falha do restante do pipeline com `gh` (no máximo 3 tentativas).
- [ ] **Comando de build/teste que o próprio agente precisa aguardar antes de decidir o próximo
  passo sempre roda em primeiro plano, bloqueando o turno até o resultado — nunca em background.** O
  harness considera o turno de um subagente "concluído" assim que ele para de emitir chamadas de
  ferramenta, mesmo que um processo real de build/teste ainda esteja rodando no sistema operacional
  em background, fora do rastreamento que dispara notificação automática. Já aconteceu de verdade:
  um `backend-developer` disparou `dotnet test`/`dotnet build` em background e encerrou o próprio
  turno sem aguardar, duas vezes seguidas — o orquestrador recebeu "tarefa concluída" quando na
  verdade era só o agente dizendo que ia esperar, sem ter esperado, e precisou monitorar processos
  do sistema operacional manualmente para descobrir quando os testes de fato terminavam. Vale para
  todo agente de implementação ou revisão deste pipeline (`backend-developer`, `frontend-developer`,
  `code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`) sempre que o comando
  decide o próximo passo da própria invocação — não é um caso a avaliar por demora esperada, mesmo
  um comando historicamente lento roda em primeiro plano até o fim.
- [ ] **Merge de PR nunca é ação de um agente — risco conhecido de agentes autônomos com escrita em
  sistemas compartilhados.** Regra 5 de `CLAUDE.md` ("Fluxo de Git = GitHub Flow") e a linha "Merge
  do PR" de `docs/GIT-WORKFLOW.md` já estabelecem que o merge é decisão do usuário; este bullet
  existe porque, numa sessão real, essa regra em texto livre não foi suficiente — o agente `sre`,
  instruído explicitamente a não mergear (no prompt de invocação e no próprio plano que ele mesmo
  documentou), mergeou um PR sozinho de qualquer forma, ativando uma configuração quebrada que
  causou um outage de produção. Nenhum agente com acesso a `Bash`/`gh` (implementador ou revisor de
  qualquer etapa) executa `gh pr merge` ou equivalente, mesmo que pareça necessário para "completar"
  a tarefa da rodada — isso vale mesmo quando o mesmo agente implementou o ajuste que está sendo
  revisado. A única exceção deliberada e documentada é a skill `/repo-issues` (manutenção deste
  próprio repositório sobre si mesmo), que mergeia os PRs que ela mesma abre só depois de aprovação
  explícita do lote pelo usuário — nunca um padrão a copiar para as etapas do pipeline SDD.
