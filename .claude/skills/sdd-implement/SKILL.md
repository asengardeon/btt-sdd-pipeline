---
name: sdd-implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona backend-developer e/ou frontend-developer (em paralelo quando a feature é full-stack) para gerar código e testes via TDD seguindo o TRD, com plano de implementação aprovado antes de qualquer código e em uma branch GitHub Flow.
---

# /sdd-implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD, em uma branch GitHub Flow (`docs/GIT-WORKFLOW.md`).

## Retomando para corrigir achados de revisão (não recomeçando do zero)

Quando `/sdd-implement` é acionado porque `/sdd-code-review`, `/sdd-qa`, `/sdd-security` ou
`/sdd-sre` reprovaram (ou levantaram achados sobre) uma fatia que um agente de implementação
(`backend-developer`/`frontend-developer`) **acabou de entregar nesta mesma sessão**, este não é o
fluxo normal de "nova fatia" — pule os passos 1-4 abaixo e trate assim:

1. Se a correção pedida é pequena e objetiva (ex.: ajustar um estado/atributo faltante, corrigir
   um valor, adicionar um teste específico apontado pelo relatório — não uma decisão de design
   nova nem redesenho de arquitetura), **prefira retomar o mesmo agente** que implementou a fatia,
   via `SendMessage` (usando o `agentId`/nome dele), em vez de invocar um agente novo do zero.
   Passe os achados do relatório de revisão (`code-review.md`/`qa-report.md`/
   `security-review.md`/`sre-review.md`) diretamente na mensagem.
1b. **Dose o contexto que você inclui na mensagem pela complexidade real da correção — não pelo
   hábito de sempre anexar tudo.** Para uma correção mecânica/pequena (ex.: um teste faltante, um
   valor incorreto, uma validação faltando), aponte o agente para o trecho específico do artefato
   relevante (a linha/seção do achado) e o(s) arquivo(s) alvo — não para o PRD/TRD inteiros nem
   para os relatórios de revisão completos. Reserve a releitura completa (PRD/TRD/relatórios
   inteiros) para quando a correção genuinamente exige julgamento/desenho novo (mesmo critério do
   passo 2 abaixo para decidir entre retomar o agente vs. acionar um novo). O custo de reler tudo é
   praticamente fixo por invocação, independente do tamanho da correção — dosar isso tem efeito
   multiplicativo em qualquer fatia que feche achados não-bloqueantes antes do merge (o caso mais
   comum de "retomar para corrigir").
2. Só prefira um agente **novo** (voltando aos passos 1-4 normais) quando: (a) a correção exige
   julgamento/desenho novo, não só aplicar o que já foi apontado; (b) o agente original já não
   está mais endereçável (sessão encerrada, `ListAgents` não o lista mais e uma tentativa de
   `SendMessage` falha); ou (c) o achado está fora do escopo do que aquele agente tocou (ex.: uma
   parte do sistema que ele nunca abriu).
2a. **Investigação de causa raiz somente-leitura, antes de decidir o que pedir ao agente, prefere
   uma sub-tarefa isolada a inflar o seu próprio contexto.** Se decidir o que pedir na correção
   exige ler vários arquivos de código, histórico de Git, ou logs — e esse conteúdo não precisa
   ficar retido depois de você chegar à conclusão do que pedir — prefira delegar essa leitura a uma
   sub-tarefa isolada que devolva só a conclusão destilada, em vez de investigar diretamente no seu
   próprio contexto de orquestrador (`docs/QUALITY-GATES.md`, seção "Governança de decisão",
   bullet sobre investigação de causa raiz). O mecanismo concreto fica a critério de qual
   ferramenta de sub-tarefa isolada está disponível no seu ambiente.
3. Retomar não abre mão de rigor: o agente retomado ainda segue TDD (teste antes da correção, red
   → green → refactor) e ainda roda a suíte completa com cobertura ao final, como no passo 5
   abaixo. A próxima rodada da mesma etapa de revisão que reprovou continua verificando o
   resultado de forma independente.
4. **Enquanto o agente retomado ainda está ativo, não dispare outra tarefa que também vá tocar
   `checkout`/`commit`/`push` na mesma branch** (ex.: uma nova rodada de revisão independente,
   ou uma verificação sua própria via `Bash`) sem isolamento — mesma regra de
   `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes". Prefira
   esperar o agente retomado terminar e confirmar que voltou para a branch base antes de invocar a
   próxima etapa; se precisar mesmo sobrepor (ex.: invocação assíncrona), use `isolation:
   "worktree"` na chamada da Agent tool para a tarefa concorrente.

## Passos (implementação de uma fatia nova)

1. Identifique o TRD: se `args` é um caminho de arquivo existente, use-o diretamente; senão,
   resolva pela convenção `specs/<slug>/trd.md` (mesma lógica de `/sdd-trd`: `args` como slug, ou
   única spec com `trd.md` sem implementação concluída, ou perguntar). Confirme que existe. Se
   não existir, sugira `/sdd-trd` primeiro. Verifique também se `docs/LESSONS-LEARNED.md` existe
   (mesmo tratamento condicional de `docs/STACK.md`/`docs/BASELINE.md`) — se existir, é passado
   como grounding adicional ao(s) agente(s) invocado(s) nos passos seguintes.
2. Leia a tabela "Decomposição de tarefas e dependências (fatias verticais de entrega)" do TRD e
   veja quais trilhas aparecem (`backend`, `frontend`, `ambos`) e a que fatia (coluna "Fatia
   (PRD)") cada tarefa pertence.
2b. Se restar mais de uma fatia vertical por implementar, **não** monte automaticamente um plano
   cobrindo todas de uma vez — cada fatia é sua própria branch/PR (`docs/GIT-WORKFLOW.md`).
   Proponha a próxima fatia pendente, na ordem da tabela (a de menor "Depende de" ainda não
   implementada), como escopo desta rodada, e confirme explicitamente com o usuário via
   `AskUserQuestion` — oferecendo as outras fatias disponíveis como alternativa — antes de montar
   o plano combinado do passo 4. Isso vale tanto para full-stack quanto para trilha única. Só bata
   múltiplas fatias numa mesma rodada (mesma branch/PR) se o usuário pedir isso explicitamente,
   deixando claro que isso abre mão da entrega incremental fatia-a-fatia.
2b-bis. **Fatias sem nenhuma trilha de código.** Antes de invocar qualquer agente, confira se
   *alguma* tarefa da fatia escolhida tem trilha `backend`/`frontend`/`ambos` associada a mudança
   de código real em `src/`/`frontend/`. Fatias inteiras podem ser só infraestrutura ou validação
   (ex.: "provisionar um add-on + confirmar em produção", trilha `infra`, `ambos (ação do
   usuário)` ou `ambos (validação)` na tabela) — sem nenhum arquivo de código a tocar. Se for o
   caso desta fatia, **pule a invocação de `backend-developer`/`frontend-developer`** e informe ao
   usuário que esta rodada será conduzida diretamente por você (o orquestrador), sem branch/PR —
   a menos que, no meio do caminho, uma mudança de infraestrutura *versionada como código* seja
   necessária (ex.: um ajuste em `cd.yml`, `Dockerfile`, `infra/terraform/`), caso em que essa
   mudança pontual vira sua própria branch/PR e passa pelo pipeline completo (code review, QA,
   segurança, SRE) normalmente, em vez de ser commitada solta.
2c. **Antes de criar a branch desta rodada**, se a fatia não é a primeira, confirme que o PR da
   fatia anterior já foi mergeado em `main` (`docs/GIT-WORKFLOW.md`, regra 3, tem o comando). Se
   não estiver, **pare aqui** e informe o usuário — não invoque os agentes de desenvolvimento
   sobre uma `main` desatualizada. Se você (ou o usuário) estiver aguardando o CI daquele PR
   terminar antes do merge, siga `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge" —
   prefira uma primeira espera maior antes da primeira checagem, em vez de checagens curtas desde
   o início. Ao confirmar o merge, atualize (se ainda não estiver) a coluna Status das tarefas
   dessa fatia anterior no TRD para `concluído (mergeado)`.
2c-ter. **Gate obrigatório: toda tarefa da fatia escolhida precisa ter Issue GitHub associada.**
   Confira a coluna "Issue GitHub" da tabela de decomposição do TRD para cada tarefa desta fatia
   (excluindo fatias sem trilha de código, passo 2b-bis, que não passam por este gate). Se alguma
   estiver vazia/`não espelhada`, **antes de concluir que a fatia está pendente**, rode uma
   checagem barata de que ela não foi implementada e mergeada sem que o TRD tivesse sido
   atualizado depois (a coluna Status pode ter ficado desatualizada mesmo com a fatia já em
   produção — ex.: `git log --oneline --all -i --grep="<slug>.*fatia N"` e/ou `gh pr list --search
   "<slug> Fatia N" --state merged`, ajustando o padrão ao texto real usado nos commits/PRs deste
   projeto). Se essa checagem encontrar um commit/PR já mergeado cobrindo as mesmas tarefas desta
   fatia, **isso é uma discrepância de documentação, não trabalho pendente**: atualize a coluna
   Status dessas tarefas no TRD para `concluído (mergeado)` citando o PR/commit real, informe o
   usuário, e volte ao passo 2b para escolher a próxima fatia realmente pendente — não crie issues
   nem branch/agente de implementação para esta fatia. Só quando a checagem não encontrar nada,
   trate como o gate original: **pare aqui, não crie a branch nem invoque nenhum agente de
   implementação** — isso não deveria acontecer se o TRD foi aprovado depois desta regra existir
   (`.claude/agents/architect.md`, passo 6c), mas pode ocorrer em TRDs aprovados antes dela, ou se
   uma issue foi apagada/perdida depois. Informe o usuário e ofereça, via `AskUserQuestion`,
   acionar `architect` para criar as issues faltantes desta fatia (opção recomendada) antes de
   prosseguir — nunca inicie a fatia sem elas, mesmo que o usuário peça para pular o gate.
3. **Se só uma trilha aparece** (só backend ou só frontend): invoque o agente correspondente
   (`backend-developer` ou `frontend-developer`, Agent tool) passando os caminhos do TRD e do
   PRD. O agente segue seu próprio processo em duas fases (plano aprovado via `AskUserQuestion`
   antes de codar) — você não precisa orquestrar isso manualmente.
4. **Se as duas trilhas aparecem** (feature full-stack): você orquestra o plano combinado antes
   de invocar os agentes. **Invocar as duas trilhas em paralelo é o padrão, não uma exceção
   cautelosa** — com isolamento de working tree garantido (passo "d" abaixo), não há mais motivo
   para serializar backend e frontend só por precaução de corrida de Git (`docs/GIT-WORKFLOW.md`,
   seção "Isolamento resolve a corrida de Git — não substitui dependência lógica entre etapas"):
   a. Leia o TRD (contrato "Frontend↔Backend" e a decomposição de tarefas), o PRD, e também
      `docs/LESSONS-LEARNED.md` se existir (mesmo tratamento condicional do passo 1) — **isto é
      necessário mesmo já tendo verificado a existência do arquivo no passo 1**, porque ao pular a
      Fase 1 dos dois agentes no passo "d" abaixo (plano já aprovado pelo orquestrador), nenhum
      deles vai ler esse arquivo por conta própria: a leitura das lições aplicáveis ao planejar
      passa a ser sua responsabilidade, não deles.
   b. Monte um plano combinado: incrementos de backend + incrementos de frontend, e como cada um
      se encaixa no contrato (ex.: "backend implementa o endpoint X no incremento 2; frontend
      constrói o client contra esse mesmo contrato, em paralelo, desde o incremento 1, usando um
      dublê até o endpoint existir de verdade") — aplicando como restrição adicional qualquer
      lição de `docs/LESSONS-LEARNED.md` relevante às trilhas de backend/frontend (mesmo critério
      que cada agente aplicaria na própria Fase 1, `docs/QUALITY-GATES.md`, seção "Lições
      aprendidas recorrentes").
   c. Apresente esse plano combinado ao usuário via `AskUserQuestion`, citando explicitamente qual
      lição de `docs/LESSONS-LEARNED.md` foi aplicada e como (se alguma foi), e só prossiga com
      aprovação explícita (mesmo limite de 3 repetições dos outros agentes — na 3ª rodada sem
      convergência, registre como VALIDAR DEPOIS no TRD e pare).
   d. Só depois de aprovado, invoque `backend-developer` e `frontend-developer` **em paralelo**
      (uma única mensagem, duas chamadas de Agent tool), cada um com a instrução explícita: "este
      plano já foi aprovado pelo orquestrador de /sdd-implement — pule sua Fase 1 e execute
      direto a sua trilha: <trilha específica do agente, extraída do plano combinado>". **Invocação
      paralela no mesmo repositório exige isolamento de working tree** (`docs/GIT-WORKFLOW.md`,
      seção "Isolamento de working tree entre agentes concorrentes") — passe `isolation: "worktree"`
      em cada chamada da Agent tool; não deixe os dois agentes dividirem o mesmo diretório de
      trabalho só porque tocam pastas diferentes (`src/` vs. `frontend/`).
5. Ao terminar (uma ou duas trilhas), confirme que cada agente rodou a **suíte completa** com
   relatório de cobertura **uma única vez, ao final da sua trilha** (não a cada task/incremento —
   durante o TDD, cada task roda só os testes que ela toca) em cada pacote afetado (`src/` e/ou
   `frontend/`) como evidência de conclusão, junto com lint sem erros, e que a branch/PR **desta
   fatia** foram de fato criados (uma única branch/PR por fatia, mesmo com as duas trilhas).
6. Mostre ao usuário um resumo do que foi implementado nesta fatia (por trilha, se full-stack), o
   link/nome do PR, os comandos usados para rodar os testes, e a cobertura obtida por pacote.
   **Inclua também uma tabela resumo do Status atual de todas as tarefas da spec** (não só desta
   fatia), extraída da coluna Status da tabela "Decomposição de tarefas e dependências" do TRD
   (colunas ID | Tarefa | Fatia | Status) — visão de progresso ponta a ponta da spec, não só do
   incremento mais recente (`docs/QUALITY-GATES.md`, seção "Status de tarefas").
7. Ao final, informe que a próxima etapa é `/sdd-code-review`, referenciando o PR desta fatia. Se
   houver fatias seguintes pendentes, informe também que elas só começam depois deste PR passar
   por code review, QA, segurança, SRE e ser mergeado em `main` (`docs/GIT-WORKFLOW.md`) — rodar
   `/sdd-implement` de novo nesta feature depois do merge retoma a partir da próxima fatia.

## Troca de provedor/serviço externo descoberta durante a implementação

Se, durante a implementação (ou um ajuste de infra pontual conduzido por você, passo 2b-bis),
surgir a necessidade de trocar um provedor/serviço externo que o TRD já desenhou com outra escolha
(ex.: TRD desenhou storage no provedor A, na prática o provedor B foi usado; TRD não especificou
provedor de e-mail transacional e um foi escolhido agora) — isso **sempre** exige, no mínimo, uma
ADR nova registrada pelo `architect` (`docs/adr/`, mesmo que pequena) **antes** do `sre` ou do
dev implementar a troca. Não é uma decisão que o orquestrador ou o `sre` tomam sozinhos caso a
caso "se merece" ADR — troca de provedor já desenhado no TRD sempre merece. Acione `architect`
(ou `/sdd-trd` se a mudança também precisa refletir no corpo do TRD) antes de prosseguir.

## Auto-aprovação nunca é o gate real

Se você (o orquestrador) pediu a um agente implementador (`backend-developer`,
`frontend-developer`, ou `sre` fazendo um ajuste pontual de infra) uma correção — mesmo pequena e
objetiva — **nunca aceite um veredito escrito por esse mesmo agente na mesma rodada** como
substituto do gate de revisão correspondente (`code-review.md`/`qa-report.md`/
`security-review.md`/`sre-review.md`). Depois que a correção estiver pronta, invoque sempre uma
instância **nova e independente** do agente de revisão apropriado — mesmo que a mudança pareça
óbvia demais para "merecer" uma rodada de revisão inteira.

**Independência não exige reexecutar tudo do zero em cada rodada intermediária.** A instância
nova e independente ainda é obrigatória (parágrafo acima não muda), mas o escopo do que ela
reexecuta pode ser proporcional ao tamanho da correção quando não é a primeira revisão da fatia —
ver `docs/QUALITY-GATES.md`, seção "Governança de decisão", bullet sobre reverificação de achado
específico. A suíte 100% completa só precisa rodar de novo, do zero, uma vez, na última rodada
antes do merge efetivo — não em toda reverificação pontual intermediária.

## Validação manual pós-merge contra produção real

Quando você (o orquestrador) faz uma validação manual pós-merge contra produção real (browser
automation, CLI do provedor, checar DNS, tail de logs, etc. — checklist em
`docs/POST-MERGE-VALIDATION.md`) para confirmar um item que `qa-report.md`/`trd.md` tinha marcado
como "VALIDAR DEPOIS" (ex.: "confirmar isso contra produção depois do deploy"), **feche o ciclo**:
rode `/sdd-amend` para marcar o(s) item(ns) `QA-N`/`TRD-N` correspondente(s) como "validado" no
artefato de origem. Não deixe isso implícito — sem esse passo, `/sdd-pending` continua listando o
item como pendente indefinidamente mesmo depois de validado de verdade.

**Teste geral obrigatório ao mergear a última fatia de uma spec.** Além de fechar itens VALIDAR
DEPOIS pontuais, se o merge que você acabou de confirmar (passo 2c) é o da **última fatia
pendente** da feature, conduza também o teste geral de fim de spec (`docs/POST-MERGE-VALIDATION.md`,
seção "Teste geral obrigatório ao finalizar uma spec") — os principais critérios de aceite do PRD
exercitados de ponta a ponta contra produção real. Isso não é opcional nem fica a critério do
usuário pedir; é parte de considerar a spec de fato concluída.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/backend-developer.md` e/ou
`.claude/agents/frontend-developer.md` diretamente, mantendo o mesmo rigor de TDD e o gate de
aprovação do plano antes de codar.
