---
name: sdd-implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona backend-developer e/ou frontend-developer (em paralelo quando a feature é full-stack) para gerar código e testes via TDD seguindo o TRD, com plano de implementação aprovado antes de qualquer código e em uma branch GitHub Flow.
---

# /sdd-implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD, em uma branch GitHub Flow (`docs/GIT-WORKFLOW.md`).

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline, de onde vêm os templates de `specs/_template/`, e como esta skill está organizada
(núcleo + detalhe sob demanda). Resolva esse caminho a partir do "Base directory" desta invocação:
via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é `docs/` dentro do
pacote.

## Índice de regras sob demanda

Leia o arquivo-filho correspondente **só quando o gatilho bater** — nunca pré-carregue todos "por
garantia" (`docs/MICRO-CONTEXT.md`, seção 1).

| Gatilho | Arquivo |
|---|---|
| Retomando agente: janela de endereçabilidade curta, reaproveitar componente com lição aberta, investigação isolada, sincronia com `main`, branch atual após retomada sem isolamento | `_rules/retomada-nuances-e-riscos.md` |
| Decidindo o alcance da validação (completa vs. escopada) de uma correção pontual | `_rules/dosagem-validacao-correcao.md` |
| A correção acrescenta `throw`/`return` de erro/caminho de exceção novo numa fatia que existe para eliminar uma classe de defeito | `_rules/correcao-nao-reintroduz-defeito.md` |
| Correção dividida em trilhas backend+frontend paralelas com contrato gerado entre elas | `_rules/reconciliacao-contrato-trilhas-paralelas.md` |
| A fatia escolhida/mergeada é a última pendente da spec | `_rules/fatia-final-bookkeeping.md` |
| Antes de invocar um agente de implementação: confirmar que o trabalho é mesmo pendente (sem trilha de código, PR já aprovado existente, issue faltando, PRD/TRD não commitado) | `_rules/fatia-sem-trabalho-pendente.md` |
| Montando o plano: pontos de entrada estruturalmente equivalentes, ou janela de convivência sendo encerrada | `_rules/plano-implementacao-detalhe.md` |
| Montando o plano: o plano depende de credencial, permissão, tag/release ou ferramenta fora do repositório | `_rules/pre-requisitos-externos.md` |
| Agente assíncrono devolveu pergunta/plano em texto puro (fallback, não o caminho esperado) | `_rules/fallback-plano-texto-puro.md` |
| Troca de provedor/serviço externo descoberta durante a implementação | `_rules/troca-de-provedor.md` |
| Validação manual pós-merge contra produção real / fechar item VALIDAR DEPOIS | `_rules/validacao-pos-merge-pendencias.md` |

## Retomando para corrigir achados de revisão (não recomeçando do zero)

Quando `/sdd-implement` é acionado porque `/sdd-code-review`, `/sdd-qa`, `/sdd-security` ou
`/sdd-sre` reprovaram (ou levantaram achados sobre) uma fatia que um agente de implementação
(`backend-developer`/`frontend-developer`) **acabou de entregar nesta mesma sessão**, este não é o
fluxo normal de "nova fatia" — pule os passos da seção "Passos" abaixo e trate assim:

1. Se a correção pedida é pequena e objetiva (ex.: ajustar um estado/atributo faltante, corrigir
   um valor, adicionar um teste específico apontado pelo relatório — não uma decisão de design
   nova nem redesenho de arquitetura), **prefira retomar o mesmo agente** que implementou a fatia,
   via `SendMessage` (usando o `agentId`/nome dele), em vez de invocar um agente novo do zero.
   Passe os achados do relatório de revisão (`code-review.md`/`qa-report.md`/
   `security-review.md`/`sre-review.md`) diretamente na mensagem. **Antes do `SendMessage`, anote o
   horário atual** (`date -u +%Y-%m-%dT%H:%M:%SZ`) — vai precisar dele para o `timing-log.md`, e a
   retomada não passa pelos passos de invocação numerados que já pedem isso.
1b. **Dose o contexto que você inclui na mensagem pela complexidade real da correção — não pelo
   hábito de sempre anexar tudo.** Para uma correção mecânica/pequena, aponte o agente para o
   trecho específico do artefato relevante e o(s) arquivo(s) alvo — não para o PRD/TRD inteiros
   nem para os relatórios de revisão completos. Reserve a releitura completa para quando a
   correção genuinamente exige julgamento/desenho novo (mesmo critério do passo 2 abaixo). O custo
   de reler tudo é praticamente fixo por invocação, independente do tamanho da correção.
2. Só prefira um agente **novo** (voltando à seção "Passos" normal) quando: (a) a correção exige
   julgamento/desenho novo, não só aplicar o que já foi apontado; (b) o agente original já não
   está mais endereçável (sessão encerrada, `ListAgents` não o lista mais e uma tentativa de
   `SendMessage` falha); ou (c) o achado está fora do escopo do que aquele agente tocou (ex.: uma
   parte do sistema que ele nunca abriu).
2b. **Promova você mesmo a coluna Status de volta para `em andamento` ao retomar uma trilha
   bloqueada.** Faça isso antes de mandar a mensagem. O agente retomado comenta a transição na
   Issue GitHub de cada tarefa, mas não edita a tabela (`.claude/agents/backend-developer.md`,
   passo 1b).
2c. **Marque você mesmo, no `tracking.md` da etapa que levantou o achado, a linha de cada achado
   que a correção endereça como `corrigido na fatia, pendente de reverificação`** (com o SHA da
   correção), no mesmo commit da correção. A rodada de reverificação do agente de revisão fecha a
   linha com a evidência (`corrigido`). Sem esta marca, a linha fica `aberto` até o fim da spec
   e a reconciliação vira um trabalho à parte, linha a linha.
3. Retomar não abre mão de rigor: o agente retomado ainda segue TDD (teste antes da correção, red
   → green → refactor) e ainda roda a suíte completa com cobertura ao final (dosagem do alcance:
   `_rules/dosagem-validacao-correcao.md`). A próxima rodada da mesma etapa de revisão que
   reprovou continua verificando o resultado de forma independente.
3b. **Registre esta invocação em `specs/<slug>/timing-log.md` também**, mesmo sendo uma correção
   ou reverificação pontual fora dos passos numerados da seção "Passos" (etapa "Correção pontual"
   ou "Reverificação pontual", agente, fatia) — mesmo mecanismo do passo 5a daquela seção (horário
   de início antes de invocar, horário atual ao terminar, diferença calculada). Vale tanto para a
   invocação de correção quanto para a reverificação pontual equivalente na etapa de revisão que a
   pediu. **Em agente retomado, nunca registre o contador bruto da notificação como custo desta
   rodada** — se não anotou o horário antes do `SendMessage`, compare contra a notificação anterior
   do mesmo agente e registre a **diferença**, nunca o bruto
   (`specs/_template/timing-log.template.md`, seção "O que a coluna 'Duração' mede").
3d. A correção não pode reintroduzir, numa forma vizinha, a classe de defeito que esta fatia/spec
   existe para eliminar: `_rules/correcao-nao-reintroduz-defeito.md`.
3e. **Se o achado é um erro opaco, peça a medição direta antes da correção — e cobre-a como
   critério de aceite da rodada.** Erro opaco é o que não nomeia sua própria causa: um `422` sem
   detalhe de campo, um overflow de N pixels, uma falha de e2e com mensagem genérica. Inclua no
   pedido que o agente **capture primeiro a evidência bruta mais próxima da causa** e só então
   formule a correção. A regra completa está em `.claude/agents/backend-developer.md`/
   `.claude/agents/frontend-developer.md` (seção "Regras inegociáveis de código", bloco sobre erro
   opaco) — aqui o ponto é que **quem pede a correção** não deixa isso implícito.
4. **Enquanto o agente retomado ainda está ativo, não dispare outra tarefa que também vá tocar
   `checkout`/`commit`/`push` na mesma branch** sem isolamento — mesma regra de
   `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes". Prefira
   esperar o agente retomado terminar e confirmar que voltou para a branch base antes de invocar a
   próxima etapa; se precisar mesmo sobrepor, use `isolation: "worktree"` na chamada da Agent tool
   para a tarefa concorrente.

Nuances e riscos adicionais de toda retomada (janela de endereçabilidade curta, reaproveitar
componente com lição aberta, investigação isolada, sincronia com `main`, branch atual após
retomada sem isolamento): `_rules/retomada-nuances-e-riscos.md`. Reconciliação de contrato gerado
entre trilhas paralelas após correção: `_rules/reconciliacao-contrato-trilhas-paralelas.md`.

## Passos (implementação de uma fatia nova)

1. Identifique o TRD: se `args` é um caminho de arquivo existente, use-o diretamente; senão,
   resolva pela convenção `specs/<slug>/trd/INDEX.md` (formato novo) ou `specs/<slug>/trd.md`
   (formato legado — `docs/MICRO-CONTEXT.md`, seção 2b) — mesma lógica de `/sdd-trd`: `args` como
   slug, ou única spec com TRD sem implementação concluída, ou perguntar. Confirme que existe. Se
   não existir, sugira `/sdd-trd` primeiro. Verifique também se `docs/LESSONS-LEARNED.md` existe
   (mesmo tratamento condicional de `docs/STACK.md`/`docs/BASELINE.md`) — se existir, é passado
   como grounding adicional ao(s) agente(s) invocado(s) nos passos seguintes.
2. Leia a tabela "Decomposição de tarefas e dependências (fatias verticais de entrega)" do TRD
   (`specs/<slug>/trd/tasks.md` no formato novo, seção 13 de `specs/<slug>/trd.md` no legado) e
   veja quais trilhas aparecem (`backend`, `frontend`, `ambos`) e a que fatia (coluna "Fatia
   (PRD)") cada tarefa pertence. Antes de concluir que não há trabalho pendente, ou de invocar
   qualquer agente: `_rules/fatia-sem-trabalho-pendente.md`; se a fatia escolhida for a última da
   spec: `_rules/fatia-final-bookkeeping.md`.
2b. Se restar mais de uma fatia vertical por implementar, **não** monte automaticamente um plano
   cobrindo todas de uma vez — cada fatia é sua própria branch/PR (`docs/GIT-WORKFLOW.md`).
   Proponha a próxima fatia pendente, na ordem da tabela (a de menor "Depende de" ainda não
   implementada), como escopo desta rodada, e confirme explicitamente com o usuário via
   `AskUserQuestion` — oferecendo as outras fatias disponíveis como alternativa — antes de montar
   o plano combinado do passo 4. Isso vale tanto para full-stack quanto para trilha única. Só bata
   múltiplas fatias numa mesma rodada (mesma branch/PR) se o usuário pedir isso explicitamente,
   deixando claro que isso abre mão da entrega incremental fatia-a-fatia.
2c. **Antes de criar a branch desta rodada**, se a fatia não é a primeira, confirme que o PR da
   fatia anterior já foi mergeado em `main` (`docs/GIT-WORKFLOW.md`, regra 3, tem o comando). Se
   não estiver, **pare aqui** e informe o usuário — não invoque os agentes de desenvolvimento
   sobre uma `main` desatualizada. Se você (ou o usuário) estiver aguardando o CI daquele PR
   terminar antes do merge, siga `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge" —
   prefira uma primeira espera maior antes da primeira checagem, em vez de checagens curtas desde
   o início. Ao confirmar o merge, atualize (se ainda não estiver) a coluna Status das tarefas
   dessa fatia anterior no TRD para `concluído (mergeado)` — e confirme também que as issues
   daquela fatia fecharam de fato (`_rules/fatia-final-bookkeeping.md`).
3. **Identifique as trilhas desta fatia** (só backend, só frontend, ou as duas) na decomposição de
   tarefas do TRD. **Em qualquer dos casos — uma trilha ou duas — quem monta e aprova o plano é
   você, o orquestrador, antes de invocar qualquer agente**: siga o passo 4. Não delegue a
   aprovação do plano ao próprio agente quando ele for invocado isolado/assíncrono
   (`isolation: "worktree"` ou equivalente), porque `AskUserQuestion` **não está disponível** nesse
   modo: o agente faz o certo e devolve o plano em texto puro sem tocar código
   (`.claude/agents/backend-developer.md`, Fase 1, passo 3), e fica parado até você intermediar
   (`_rules/fallback-plano-texto-puro.md`). Isso já custou **~4h30m de relógio numa única fatia de
   trilha única**. A única situação em que o agente conduz a própria Fase 1 é quando ele roda **no
   mesmo contexto, síncrono, com `AskUserQuestion` disponível para ele**; na dúvida, planeje você.
4. **Monte e aprove o plano antes de invocar** — uma trilha ou duas. Com as duas trilhas (feature
   full-stack), o plano é combinado e **invocar as duas em paralelo é o padrão, não uma exceção
   cautelosa**: com isolamento de working tree garantido, não há mais motivo para serializar
   backend e frontend só por precaução de corrida de Git (`docs/GIT-WORKFLOW.md`, seção
   "Isolamento resolve a corrida de Git — não substitui dependência lógica entre etapas").
   a. Leia o TRD (a decomposição de tarefas e, com as duas trilhas, o contrato
      "Frontend↔Backend"), o PRD, e também `docs/LESSONS-LEARNED.md` se existir — **isto é
      necessário mesmo já tendo verificado a existência do arquivo no passo 1**, porque ao pular a
      Fase 1 do(s) agente(s) no passo "d" abaixo, nenhum deles vai ler esse arquivo por conta
      própria: a leitura das lições aplicáveis ao planejar passa a ser sua responsabilidade.
   b. Monte o plano: os incrementos pequenos e testáveis da trilha (idealmente um por caso de
      uso), na ordem em que serão implementados. Com as duas trilhas, é um plano **combinado** —
      incrementos de backend + incrementos de frontend, e como cada um se encaixa no contrato
      (ex.: "backend implementa o endpoint X no incremento 2; frontend constrói o client contra
      esse mesmo contrato, em paralelo, desde o incremento 1, usando um dublê até o endpoint
      existir de verdade") — aplicando como restrição adicional qualquer lição de
      `docs/LESSONS-LEARNED.md` relevante. Dois casos específicos a verificar antes de fechar o
      plano: `_rules/plano-implementacao-detalhe.md`. Se o plano depende de algo fora do
      repositório (credencial, permissão, tag/release, ferramenta local), verifique antes de
      apresentá-lo: `_rules/pre-requisitos-externos.md`.
   c. Apresente esse plano ao usuário via `AskUserQuestion`, citando explicitamente qual lição de
      `docs/LESSONS-LEARNED.md` foi aplicada e como (se alguma foi), e só prossiga com aprovação
      explícita (mesmo limite de 3 repetições dos outros agentes — na 3ª rodada sem convergência,
      registre como VALIDAR DEPOIS no TRD e pare).
   c2. **Commite o plano aprovado como `specs/<slug>/plans/F-<N>.md`** (a partir de
      `specs/_template/plan.template.md`), antes de invocar qualquer agente — arquivos que mudam,
      ordem dos incrementos por trilha, riscos, lições aplicadas. `code-reviewer` lê este arquivo
      quando existir e confere o diff contra ele, além do TRD. Se a implementação final se afastar
      do plano, registre a divergência na seção correspondente do mesmo arquivo, no mesmo commit
      em que ela aparecer — nunca reescreva o plano original para fingir que já previa o desvio.
   d. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 5a
      para registrar a duração de cada trilha. Só depois de aprovado, invoque o(s) agente(s) —
      **com as duas trilhas, em paralelo** (uma única mensagem, duas chamadas de Agent tool) —,
      cada um com a instrução explícita: "este plano já foi aprovado pelo orquestrador de
      /sdd-implement — pule sua Fase 1 e execute direto a sua trilha: <trilha específica do
      agente, extraída do plano>". Essa frase não é opcional: sem ela o agente roda a própria Fase
      1, não consegue perguntar, e para. **Invocação paralela no mesmo repositório exige
      isolamento de working tree** (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree
      entre agentes concorrentes") — passe `isolation: "worktree"` em cada chamada da Agent tool;
      não deixe os dois agentes dividirem o mesmo diretório de trabalho só porque tocam pastas
      diferentes (`src/` vs. `frontend/`).
      **Se o worktree isolado não consegue usar `git`** (hook do ambiente recusa todo comando e o
      agente não executa nenhuma tarefa), rode as trilhas em sequência no diretório principal,
      backend primeiro. O custo é perder o paralelismo; registre isso no plano e na rodada.
   e. **Promova a coluna Status das tarefas desta fatia para `em andamento` você mesmo, numa
      única passada, antes de invocar as trilhas.** Os agentes de implementação não editam essa
      transição — só comentam na Issue GitHub de cada tarefa. É simétrico à promoção para
      `implementado` do passo 5, e pelo mesmo motivo: duas trilhas despachadas em paralelo
      editariam a mesma coluna da mesma tabela no mesmo minuto.
5. Ao terminar (uma ou duas trilhas), confirme que cada agente rodou a **suíte completa** com
   relatório de cobertura **uma única vez, ao final da sua trilha** em cada pacote afetado
   (`src/` e/ou `frontend/`) como evidência de conclusão, junto com lint sem erros, e que a
   branch/PR **desta fatia** foram de fato criados (uma única branch/PR por fatia, mesmo com as
   duas trilhas). **Se esta rodada gravou uma revisão nova no "Log de revisões" do TRD** (ex.: uma
   premissa refutada por medição, um contrato observável que mudou na implementação), faça antes a
   **passada de coerência das seções 9, 13 e 14** descrita em `.claude/skills/sdd-amend/SKILL.md`,
   passo 3.
   **Promova a coluna Status das tarefas desta fatia para `implementado` você mesmo, numa única
   passada, depois de confirmar as duas trilhas integradas na branch compartilhada** —
   `backend-developer`/`frontend-developer` não editam mais essa transição no próprio commit final
   (fica só o comentário na Issue GitHub de cada um): duas trilhas terminando em paralelo e
   editando a mesma tabela do TRD na última task já causou um conflito mecânico real de merge
   nessa coluna. Fazer essa transição numa única passada do orquestrador elimina o conflito por
   completo. **No mesmo commit em que o PR da fatia é aberto, atualize a seção 14 do TRD**
   ("Controle de versão (GitHub Flow, por fatia)") com o número real do PR e status "em revisão"
   (`docs/GIT-WORKFLOW.md`, regra 4) — sem isso, a seção 14 fica mostrando "não iniciado" para uma
   fatia que já tem PR aberto até uma etapa de revisão posterior notar e corrigir (issue #486,
   `asengardeon/btt-sdd-pipeline`).
5a. **Registre a duração desta rodada em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha por trilha invocada
   nesta rodada (etapa "Implementação", agente "backend-developer" e/ou "frontend-developer",
   fatia desta rodada), com o horário anotado no passo 3/4d, o horário atual, e a diferença
   calculada. **Se esta rodada incluiu uma pausa para aprovação humana** (passo 5b do fallback),
   a diferença bruta de horários **não** é o número a registrar: some as durações reais das
   invocações de subagente envolvidas e registre isso, com nota parentética explícita dizendo que
   exclui a espera de aprovação. **Se você, o orquestrador, conduziu trabalho próprio nesta
   etapa**, registre-o como uma linha própria com `Agente = orquestrador (sem agente)`, em vez de
   deixá-lo invisível no log. **Uma linha por etapa, sempre**
   (`specs/_template/timing-log.template.md`). Diferente de PRD/TRD, aqui já existe branch/PR —
   commit e envie (push) essa atualização junto com o resto do que esta rodada já for commitar.
5c. **Confira o corpo do PR contra as issues da fatia antes de seguir.** Compare `gh pr view <PR>
   --json closingIssuesReferences` com a coluna "Issue GitHub" das tarefas desta fatia na seção
   13 do TRD. Falta alguma? Leia o corpo atual (`gh pr view <PR> --json body`) e acrescente uma
   linha `Closes #N` por issue que faltar — nunca reescreva o corpo do zero. Os agentes de
   implementação já recebem esta regra (`.claude/agents/backend-developer/pr-step1-mecanica.md`),
   mas só você confere o resultado das duas trilhas juntas.
6. Mostre ao usuário um resumo do que foi implementado nesta fatia (por trilha, se full-stack), o
   link/nome do PR, os comandos usados para rodar os testes, e a cobertura obtida por pacote.
   **Inclua também uma tabela resumo do Status atual de todas as tarefas da spec** (não só desta
   fatia), extraída da coluna Status da tabela "Decomposição de tarefas e dependências" do TRD
   (colunas ID | Tarefa | Fatia | Status) — visão de progresso ponta a ponta da spec, não só do
   incremento mais recente (`docs/gates/status-de-tarefas.md`).
7. Ao final, informe que a próxima etapa é `/sdd-code-review`, referenciando o PR desta fatia. Se
   houver fatias seguintes pendentes, informe também que elas só começam depois deste PR passar
   por code review, QA, segurança, SRE e ser mergeado em `main` (`docs/GIT-WORKFLOW.md`) — rodar
   `/sdd-implement` de novo nesta feature depois do merge retoma a partir da próxima fatia.

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
ver `docs/gates/governanca.md`, bullet sobre reverificação de achado
específico. A suíte 100% completa só precisa rodar de novo, do zero, uma vez, na última rodada
antes do merge efetivo — não em toda reverificação pontual intermediária.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/backend-developer.md` e/ou
`.claude/agents/frontend-developer.md` diretamente, mantendo o mesmo rigor de TDD e o gate de
aprovação do plano antes de codar.
