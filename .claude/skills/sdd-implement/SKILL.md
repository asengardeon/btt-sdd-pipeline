---
name: sdd-implement
description: Etapa 3 do pipeline SDD. Use depois que um TRD existe e foi aprovado, para implementar a feature em código. Aciona backend-developer e/ou frontend-developer (em paralelo quando a feature é full-stack) para gerar código e testes via TDD seguindo o TRD, com plano de implementação aprovado antes de qualquer código e em uma branch GitHub Flow.
---

# /sdd-implement

Aciona a **etapa 3** do pipeline SDD descrito em `CLAUDE.md`: implementação via TDD a partir do
TRD, em uma branch GitHub Flow (`docs/GIT-WORKFLOW.md`).

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação): se for
`.claude/skills/<esta-skill>/` apontando para este repositório via junction global (`CLAUDE.md`,
seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo repositório** —
não necessariamente no projeto onde você está trabalhando agora. Se o projeto atual também tiver
um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`, `LESSONS-LEARNED.md`, `adr/`), esse é
conteúdo do projeto, não deste pipeline — não confunda os dois.

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
1c. **A janela de endereçabilidade do agente retomado no passo 1 pode ser bem mais curta do que
   parece razoável supor** — já expirou em menos de 1h de wall-clock dentro da mesma sessão,
   preenchida só por outras duas invocações de subagente da mesma spec (não horas, nem a sessão
   inteira ter encerrado). Sempre tente `SendMessage` primeiro (é barato), mas **já formule o
   pedido de correção do passo 1 de um jeito que funcione igualmente bem como prompt de abertura
   para um agente novo** — caminhos de arquivo/linha explícitos, não referências implícitas a "o
   que você acabou de fazer" — assim, se a retomada falhar (item `b` do passo 2 abaixo), o fallback
   para agente novo não exige reformular o pedido do zero.
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
3a. **Dose também o custo de validação pelo alcance real da correção — simétrico à dosagem de
   contexto do passo 1b.** Rodar a suíte completa local continua sendo o padrão **sempre que a
   correção toca comportamento de produção**. Mas se o diff da correção **não toca nenhum arquivo de
   `src/`/`frontend/`** (ex.: só acrescenta casos de teste, só ajusta um comentário/doc), ou toca
   apenas código que a suíte rápida cobre integralmente, a validação local pode ser **escopada aos
   módulos afetados** — desde que **o CI do PR fique verde no commit final**, que é o gate real. Se
   escopar, o relatório da rodada declara explicitamente o que foi rodado localmente, o que foi
   delegado ao CI, e por quê — a omissão dessa declaração é que transforma escopar em atalho
   silencioso. Já aconteceu de verdade: uma rodada de correção que mudou **3 `InlineData` num
   arquivo de teste e um comentário**, zero linhas de comportamento, foi a etapa mais longa da fatia
   inteira (41m14s, mais que a implementação) — gasta rodando duas vezes uma suíte de integração com
   navegador real que a correção não podia afetar, ambas vermelhas por flakiness de ambiente. Na
   mesma fatia, os mesmos testes passaram verdes de primeira nos dois runs de CI em runner dedicado,
   sem rerun: em ambiente de desenvolvimento contendido, o CI é o sinal **mais** confiável, não
   menos. Isso não vale como desculpa para pular validação de uma correção que mexe em produção —
   ali a suíte completa local continua obrigatória antes de empurrar para o CI.
3b. **Registre esta invocação em `specs/<slug>/timing-log.md` também**, mesmo sendo uma correção ou
   reverificação pontual fora dos passos numerados 1-5 (etapa "Correção pontual" ou "Reverificação
   pontual", agente, fatia) — mesmo mecanismo do passo 5a abaixo (horário de início antes de
   invocar, horário atual ao terminar, diferença calculada). Vale tanto para a invocação de
   correção (`backend-developer`/`frontend-developer`, este passo) quanto para a reverificação
   pontual equivalente na etapa de revisão que a pediu (`code-reviewer`/`qa-engineer`/
   `security-engineer`/`sre` — mesma observação nas skills dessas etapas). Sem isso, o
   `timing-log.md` de uma fatia com achados fica sistematicamente incompleto, reduzindo a precisão
   de qualquer análise de performance futura (ex.: a retrospectiva do próprio `sre`, que lê este
   arquivo).
3d. **Se esta fatia (ou a spec inteira) existe para eliminar uma classe de defeito, verifique
   explicitamente que a correção do achado não a reintroduz numa forma vizinha** — e inclua essa
   verificação no pedido que você manda ao agente, em vez de esperar que ele lembre. O risco é
   estrutural, não descuido: a atenção de todos está no **achado** (o que foi apontado), não na
   **classe** (o que a feature existe para impedir), e a correção é pequena, o que desarma a
   desconfiança. O sinal de alerta mais forte é a correção **acrescentar um `throw`, um `return` de
   erro, ou qualquer caminho de exceção novo**. A pergunta a fazer não é "isto resolve o achado?",
   e sim **"se isto disparar, o resultado é melhor ou pior que a violação que ele guarda?"**. Já
   aconteceu de verdade: uma fatia existia para impedir que uma exceção lançada de dentro de um
   caminho de reporte de falha derrubasse o lote inteiro (via `Task.WhenAll`) em vez de falhar só
   aquela linha; na fatia seguinte, a correção de uma ressalva legítima do `code-reviewer`
   acrescentou `_ => throw new NotSupportedException(...)` **dentro do mesmo método de renderização
   de falha** — passando pelo desenvolvedor *e* pelo revisor que levantou a ressalva, porque ambos
   olhavam para "a categoria fica sem declaração?" e não para "o que acontece se isto disparar?".
   Três medições desfizeram o caso: acrescentar uma categoria real ao enum e compilar mostrou 0
   avisos (o braço `_` suprime o aviso de exaustividade — a "rede de compilação" que justificaria o
   `throw` nunca existiu, ele a *custava*); o caminho real era avaliação ávida dentro de um `catch`,
   sem `catch` externo; e no cenário em que dispara, o resultado é **pior** que a violação que ele
   guarda — o invariante era "nunca uma falha sem classificação", e o `throw` não produz falha sem
   classificação, produz **nenhum relatório para nenhuma linha**, inclusive as bem-sucedidas. A
   forma final foi degradação local + teste de exaustividade mais apertado.
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
2a. **Se nenhuma fatia estiver pendente** (todas as tarefas da tabela já implementadas/mergeadas —
   `.claude/skills/sdd-status/scripts/sdd-status.sh`/`.ps1`, função `has_fatia_pendente`/
   `Test-FatiaPendente`, agora cruza com o estado real do PR antes de confiar cegamente no texto da
   coluna Status), **antes de simplesmente informar que não há trabalho a fazer**, confirme se a
   promoção de Status da **última fatia** da tabela já aconteceu. O mecanismo normal de promoção
   para `concluído (mergeado)` (`docs/QUALITY-GATES.md`, seção "Status de tarefas") só dispara "ao
   confirmar, antes de iniciar a fatia seguinte, que o PR de uma fatia já foi mergeado" — e a
   última fatia de uma spec nunca tem uma fatia seguinte para disparar isso, então a tarefa fica
   presa no status que o `sre` deixou (`aprovado`), mesmo depois de mergeada de verdade. Verifique
   o PR referenciado na coluna Status/Issue GitHub da última fatia (`gh pr view <N> --json
   state,mergedAt`); se estiver mergeado e a coluna Status ainda não disser `concluído (mergeado)`,
   promova-a agora (mesma transição de sempre, só aplicada retroativamente por não haver "fatia
   seguinte" que a disparasse). Se essa promoção nunca tinha acontecido antes, é sinal de que o
   "Teste geral obrigatório ao mergear a última fatia de uma spec" (seção abaixo) também pode nunca
   ter rodado — confirme com o usuário se já rodou antes de considerar a spec de fato encerrada. Já
   aconteceu de verdade em 7 specs diferentes de um mesmo projeto: todas 100% implementadas e
   mergeadas, mas a tabela continuava reportando "próxima fatia pendente" indefinidamente.
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
2b-ter. **Antes de invocar qualquer agente para a fatia escolhida, confirme que não existe já um
   PR aberto e totalmente aprovado cobrindo as mesmas tarefas** — independente de a coluna "Issue
   GitHub" estar preenchida (esse é o gate do passo 2c-ter, condição diferente). Rode `gh pr list
   --state open --search "<slug> Fatia N"` (ajustando o padrão ao texto real usado nos PRs deste
   projeto). Se encontrar um PR aberto cujos artefatos de revisão (`code-review.md`/`qa-report.md`/
   `security-review.md`/`sre-review.md`) já estão todos aprovados para essa fatia, isso é
   **trabalho pronto aguardando merge, não trabalho pendente** — pare aqui, não invoque
   `backend-developer`/`frontend-developer`, informe o usuário do PR encontrado e sugira mergear em
   vez de reimplementar (o merge em si continua sendo decisão do usuário, `docs/GIT-WORKFLOW.md`).
   Só prossiga para os passos seguintes quando essa checagem não encontrar nenhum PR aberto já
   aprovado para a fatia. Já aconteceu de verdade: a tabela do TRD reportava a fatia F-1 inteira
   como `pendente` porque a promoção de Status só dispara ao confirmar merge da fatia anterior
   antes de iniciar a próxima (passo 2c) — mas o PR da fatia já existia, com code review, QA,
   segurança e SRE todos aprovados e CI verde, só faltando o merge; sem uma checagem manual, o
   trabalho teria sido reimplementado do zero.
2c. **Antes de criar a branch desta rodada**, se a fatia não é a primeira, confirme que o PR da
   fatia anterior já foi mergeado em `main` (`docs/GIT-WORKFLOW.md`, regra 3, tem o comando). Se
   não estiver, **pare aqui** e informe o usuário — não invoque os agentes de desenvolvimento
   sobre uma `main` desatualizada. Se você (ou o usuário) estiver aguardando o CI daquele PR
   terminar antes do merge, siga `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge" —
   prefira uma primeira espera maior antes da primeira checagem, em vez de checagens curtas desde
   o início. Ao confirmar o merge, atualize (se ainda não estiver) a coluna Status das tarefas
   dessa fatia anterior no TRD para `concluído (mergeado)`.
2c-quater. **Ao confirmar esse merge, confirme também que todas as issues daquela fatia fecharam de
   fato** — `gh pr view <PR> --json closingIssuesReferences` (ou `gh issue view <N> --json state`
   para cada issue da coluna "Issue GitHub" daquela fatia). As que sobrarem abertas, feche à mão
   citando o PR (`gh issue close <N> --comment "Fechada por #<PR>"`). Não assuma que o `Closes`
   funcionou: a forma com vírgulas simples (`Closes #A, #B, #C`) fecha **só a primeira** em
   silêncio, e o corpo do PR *parece* correto (`docs/GIT-WORKFLOW.md`, regras 5b e 5c). Uma issue
   que ficou aberta sem motivo faz esta spec parecer ter trabalho pendente que já está em produção
   — e, no limite, faz o gate do passo 2c-ter levar uma fatia futura a **reimplementar** o que já
   foi mergeado, exatamente o cenário que o passo 2b-ter existe para evitar.
2c-bis. **Ao criar a branch desta rodada, garanta que o PRD/TRD desta spec estão commitados em
   algum ref antes de invocar qualquer agente com `isolation: "worktree"`.** Um `git worktree add`
   cria um checkout limpo a partir de um ref já commitado — mudanças feitas diretamente no checkout
   principal (ex.: a edição do PRD/TRD durante a aprovação, que por si só não passa por commit/PR,
   `docs/GIT-WORKFLOW.md`, seção "Mapeamento no pipeline SDD": "Nenhuma — documentos em `specs/`,
   sem código/branch ainda") são literalmente invisíveis para um worktree novo, mesmo que `git log
   --all` seja consultado. Se `specs/<slug>/prd.md`/`trd.md` (e `timing-log.md`, se as etapas de
   PRD/TRD já o criaram — `specs/_template/timing-log.template.md`) ainda estiverem só como
   mudanças não commitadas no checkout principal, commite-os agora, nesta branch recém-criada, como
   parte do primeiro commit — antes de qualquer `git worktree add`/invocação com `isolation:
   "worktree"` para esta fatia. **Nunca** contorne isso commitando PRD/TRD direto em `main` (regra 1
   de `docs/GIT-WORKFLOW.md` — ninguém commita direto nela) nem criando um PR de documentação avulso
   para isso — eles seguem incluídos no mesmo PR desta fatia, revisados normalmente como o resto do
   conteúdo da branch. Já aconteceu de verdade: um agente invocado com `isolation: "worktree"`
   falhou de cara porque o TRD da spec só existia como arquivo não commitado no checkout principal
   — uma implementação inteira precisou ser refeita (~28k tokens) até alguém perceber e commitar
   manualmente. Se duas specs em paralelo estão nessa mesma situação, cada uma resolve isso na
   própria branch — nunca aproveite para commitar o PRD/TRD de uma spec na branch de outra.
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
3. **Identifique as trilhas desta fatia** (só backend, só frontend, ou as duas) na decomposição de
   tarefas do TRD. **Em qualquer dos casos — uma trilha ou duas — quem monta e aprova o plano é
   você, o orquestrador, antes de invocar qualquer agente**: siga o passo 4. Não delegue a
   aprovação do plano ao próprio agente quando ele for invocado isolado/assíncrono
   (`isolation: "worktree"` ou equivalente), porque `AskUserQuestion` **não está disponível** nesse
   modo: o agente faz o certo e devolve o plano em texto puro sem tocar código
   (`.claude/agents/backend-developer.md`, Fase 1, passo 3), e fica parado até você intermediar.
   Isso já custou **~4h30m de relógio numa única fatia de trilha única**, medidas e registradas no
   `timing-log.md` da spec como custo do pipeline — 2ª ocorrência do mesmo mecanismo. A única
   situação em que o agente conduz a própria Fase 1 é quando ele roda **no mesmo contexto,
   síncrono, com `AskUserQuestion` disponível para ele**; na dúvida, planeje você.
4. **Monte e aprove o plano antes de invocar** — uma trilha ou duas. Com as duas trilhas (feature
   full-stack), o plano é combinado e **invocar as duas em paralelo é o padrão, não uma exceção
   cautelosa**: com isolamento de working tree garantido (passo "d" abaixo), não há mais motivo
   para serializar backend e frontend só por precaução de corrida de Git (`docs/GIT-WORKFLOW.md`,
   seção "Isolamento resolve a corrida de Git — não substitui dependência lógica entre etapas"):
   a. Leia o TRD (a decomposição de tarefas e, com as duas trilhas, o contrato "Frontend↔Backend"),
      o PRD, e também `docs/LESSONS-LEARNED.md` se existir (mesmo tratamento condicional do passo 1)
      — **isto é necessário mesmo já tendo verificado a existência do arquivo no passo 1**, porque
      ao pular a Fase 1 do(s) agente(s) no passo "d" abaixo (plano já aprovado pelo orquestrador),
      nenhum deles vai ler esse arquivo por conta própria: a leitura das lições aplicáveis ao
      planejar passa a ser sua responsabilidade, não deles.
   b. Monte o plano: os incrementos pequenos e testáveis da trilha (idealmente um por caso de uso),
      na ordem em que serão implementados. Com as duas trilhas, é um plano **combinado** —
      incrementos de backend + incrementos de frontend, e como cada um se encaixa no contrato (ex.: "backend implementa o endpoint X no incremento 2; frontend
      constrói o client contra esse mesmo contrato, em paralelo, desde o incremento 1, usando um
      dublê até o endpoint existir de verdade") — aplicando como restrição adicional qualquer
      lição de `docs/LESSONS-LEARNED.md` relevante às trilhas de backend/frontend (mesmo critério
      que cada agente aplicaria na própria Fase 1, `docs/QUALITY-GATES.md`, seção "Lições
      aprendidas recorrentes"). **Se esta fatia toca múltiplos pontos de entrada estruturalmente
      equivalentes** (mesmo padrão de UI/lógica duplicado em N lugares — ex.: N formulários usando
      o mesmo hook compartilhado, N validações idênticas em rotas irmãs), inclua no plano
      explicitamente: "paridade de teste em todos os N pontos, não só paridade de implementação" —
      já aconteceu de uma correção sair correta em todos os pontos, mas só alguns ganharem teste
      dedicado ao novo caminho, achado só pelo `code-reviewer` numa rodada extra evitável. **Se esta
      fatia introduz o endpoint/rota *permanente* de uma "janela de convivência" já desenhada no
      TRD** (uma rota temporária de fatia anterior sendo suplantada — TRD, seção "Janelas de quebra
      de contrato entre fatias"), não presuma que um consumidor de frontend que já compila contra a
      rota temporária "já está pronto, sem mudança necessária" só porque a assinatura bate: rode
      `grep` pelo caminho da rota temporária em `frontend/src` antes de escrever a instrução da
      trilha frontend, e se encontrar uso, inclua no plano a migração explícita para a rota
      permanente — a rota temporária pode ser removida por uma fatia futura, e um consumidor não
      migrado quebra silenciosamente em produção nesse momento.
   c. Apresente esse plano ao usuário via `AskUserQuestion`, citando explicitamente qual
      lição de `docs/LESSONS-LEARNED.md` foi aplicada e como (se alguma foi), e só prossiga com
      aprovação explícita (mesmo limite de 3 repetições dos outros agentes — na 3ª rodada sem
      convergência, registre como VALIDAR DEPOIS no TRD e pare).
   d. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 5a
      para registrar a duração de cada trilha. Só depois de aprovado, invoque o(s) agente(s) —
      **com as duas trilhas, em paralelo** (uma única mensagem, duas chamadas de Agent tool) —,
      cada um com a instrução explícita: "este plano já foi aprovado pelo orquestrador de
      /sdd-implement — pule sua Fase 1 e execute direto a sua trilha: <trilha específica do
      agente, extraída do plano>". Essa frase não é opcional: sem ela o agente roda a própria Fase 1,
      não consegue perguntar, e para. **Invocação paralela no mesmo repositório exige isolamento de
      working tree** (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes
      concorrentes") — passe `isolation: "worktree"` em cada chamada da Agent tool; não deixe os
      dois agentes dividirem o mesmo diretório de trabalho só porque tocam pastas diferentes
      (`src/` vs. `frontend/`).
5. Ao terminar (uma ou duas trilhas), confirme que cada agente rodou a **suíte completa** com
   relatório de cobertura **uma única vez, ao final da sua trilha** (não a cada task/incremento —
   durante o TDD, cada task roda só os testes que ela toca) em cada pacote afetado (`src/` e/ou
   `frontend/`) como evidência de conclusão, junto com lint sem erros, e que a branch/PR **desta
   fatia** foram de fato criados (uma única branch/PR por fatia, mesmo com as duas trilhas).
   **Promova a coluna Status das tarefas desta fatia para `implementado` você mesmo, numa única
   passada, depois de confirmar as duas trilhas integradas na branch compartilhada** —
   `backend-developer`/`frontend-developer` não editam mais essa transição no próprio commit final
   (fica só o comentário na Issue GitHub de cada um): duas trilhas terminando em paralelo e
   editando a mesma tabela do TRD na última task já causou um conflito mecânico real de merge
   nessa coluna. Fazer essa transição numa única passada do orquestrador, depois de já ter as duas
   trilhas na mesma branch, elimina o conflito por completo.
5a. **Registre a duração desta rodada em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha por trilha invocada
   nesta rodada (etapa "Implementação", agente "backend-developer" e/ou "frontend-developer", fatia
   desta rodada), com o horário anotado no passo 3 (trilha única) ou 4d (full-stack — mesmo horário
   de início para as duas linhas, já que rodam em paralelo), o horário atual, e a diferença
   calculada. **Se esta rodada incluiu uma pausa para aprovação humana** (o agente devolveu o plano
   da Fase 1 e ficou parado até o usuário responder — passo 5b abaixo), a diferença bruta de
   horários **não** é o número a registrar: some as durações reais das invocações de subagente
   envolvidas (o `duration_ms` de cada notificação de conclusão) e registre isso, com nota
   parentética explícita dizendo que exclui a espera de aprovação
   (`specs/_template/timing-log.template.md`, seção "O que a coluna 'Duração' mede"). Uma espera de
   aprovação de horas registrada como wall-clock puro faz a retrospectiva do `sre` concluir que a
   implementação foi anormalmente lenta quando não foi. Diferente de PRD/TRD (passo 2c-bis), aqui
   já existe branch/PR — commit e envie (push)
   essa atualização junto com o resto do que esta rodada já for commitar (não é um push extra só
   para isso, salvo se nada mais estiver pendente — `docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar
   pushes relacionados).
5b. **Fallback, não o caminho esperado.** Com o passo 4 seguido, o plano já foi aprovado por você
   antes da invocação e nenhum agente devolve plano em texto puro. Este passo existe para o desvio:
   **se `backend-developer`/`frontend-developer` estiver rodando como subagente assíncrono/em
   background (`isolation: "worktree"` ou equivalente) e devolver uma pergunta/plano em texto puro**
   (sinal de que `AskUserQuestion` não estava disponível para ele nesse modo — mesmo padrão já
   documentado para `sre`/`/sdd-sre`, `.claude/skills/sdd-sre/SKILL.md`, passo 4b), o tratamento
   depende de **quando** isso aconteceu:
   - **Ambiguidade pontual no meio da execução ou no resumo final** (o agente já seguiu com a
     alternativa mais conservadora e registrou a pendência): **você** — o orquestrador desta
     skill — é responsável por apresentar essa pergunta ao usuário via *sua própria*
     `AskUserQuestion` e repassar a resposta de volta ao agente (`SendMessage`, se ele ainda estiver
     ativo/endereçável) antes de considerar a trilha concluída. Nunca deixe a pergunta sem resposta
     só porque o agente já seguiu em frente registrando-a como pendência — isso é aceitável como
     fallback do próprio agente (nenhuma suposição silenciosa ainda assim vira "VALIDAR DEPOIS" no
     artefato), mas não dispensa você de tentar obter a resposta real do usuário nesta mesma rodada
     quando possível.
   - **O plano inteiro da Fase 1 voltou em texto puro, sem nenhuma implementação ainda** (o agente
     parou de propósito, sem tocar código — `.claude/agents/backend-developer.md`/
     `.claude/agents/frontend-developer.md`, Fase 1, passo 3): **nunca trate isso como se já fosse
     conclusão da trilha.** Apresente o plano ao usuário via sua própria `AskUserQuestion` e, só
     depois de aprovação explícita, retome o agente (`SendMessage`) autorizando a Fase 2. O agente
     fica parado indefinidamente até essa retomada — diferente do caso anterior, aqui não há
     trabalho de trilha em andamento para "considerar concluído": não existe ainda. Chegar aqui
     significa que a instrução "este plano já foi aprovado pelo orquestrador" do passo 4d não foi
     passada: a parada é recuperável, mas o custo dela (horas de relógio) é justamente o que o
     passo 4 existe para evitar.
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
