---
name: hotfix
description: Correção pontual pós-merge, fora do ciclo normal de fatias do pipeline SDD. Use quando um bug é encontrado em produção (ou numa validação manual) depois que a spec relacionada já foi mergeada, ou para uma melhoria pontual sem spec de origem — sem PRD/TRD, mas ainda com TDD e as revisões relevantes (code review sempre; QA/segurança/SRE conforme o critério desta skill).
---

# /btt-sdd:hotfix

Formaliza o processo de **correção pontual pós-merge**: um bug encontrado em produção (ou numa
validação manual) depois que a spec relacionada já concluiu o pipeline e foi mergeada, ou uma
melhoria pontual sem spec de origem nenhuma. Diferente das 7 etapas normais (`docs/SDD-WORKFLOW.md`),
esta skill **não gera PRD nem TRD** — o pedido já é concreto o suficiente (um bug específico, um
ajuste pontual) para não justificar o levantamento de produto/arquitetura completo. Isso não é uma
saída para pular rigor: TDD, code review, e as revisões que se aplicarem continuam obrigatórias.

## Quando usar

- Um bug foi encontrado em produção (ou durante `docs/POST-MERGE-VALIDATION.md`) numa feature cuja
  spec já está com todas as fatias mergeadas — não é o caso de "fatia ainda em andamento" (isso
  volta para `/btt-sdd:implement` normalmente, achados de revisão da própria fatia).
- Uma melhoria pontual e de baixo risco é pedida sem nenhuma spec de origem (nunca passou por
  `/btt-sdd:prd`).
- **Não use** para uma mudança que na prática é uma feature nova (critério de aceite novo,
  decisão de arquitetura relevante, mais de uma fatia de esforço) — isso é `/btt-sdd:prd`
  normalmente, mesmo que o pedido pareça pequeno à primeira vista. Se a correção crescer em
  escopo/risco no meio da execução desta skill, pare e migre para o fluxo completo em vez de
  continuar aqui.

## Passos

1. **Identifique a spec relacionada, se houver.** Se o bug está numa área de código que uma spec
   existente em `specs/` introduziu ou alterou por último, essa é a spec relacionada — os
   artefatos desta rodada (`code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md`)
   são editados **in-place** nela, com uma linha nova na respectiva "Histórico de aprovações por
   fatia" usando `hotfix-<data>` (ex.: `hotfix-2026-09-01`) no lugar do identificador de fatia
   (`F-N`). Se não há nenhuma spec relacionada (melhoria pontual sem origem), crie um diretório
   dedicado `specs/<NNNN>-<slug-curto>/` (próximo número sequencial livre em `specs/`) contendo só
   os artefatos de revisão que se aplicarem — sem `prd.md`/`trd.md`.
1b. **Gate obrigatório: confirme/crie a Issue GitHub deste hotfix antes de criar a branch.**
   Verifique remote GitHub configurado e autenticado (`git remote -v`, `gh auth status`).
   - **Se houver**: se o bug/ajuste já tem uma issue aberta (o usuário citou o número, ou ela
     existe no repositório), use-a; senão crie uma via `gh issue create` descrevendo o
     bug/ajuste, com o label de tipo apropriado (`bug` ou `enhancement`). Nenhum hotfix começa
     sem essa issue — sem exceção, mesmo para uma correção de uma linha. **Se o passo 1 identificou
     uma spec relacionada**, identifique essa issue estruturadamente contra ela
     (`docs/QUALITY-GATES.md`, seção "TRD"): reaproveite o milestone da spec se ele já existir (`gh
     api repos/<owner>/<repo>/milestones` filtrando por título `<slug>` — o mesmo milestone que o
     agente `architect` cria por spec); se ainda não existir nenhum milestone para essa
     spec/projeto (spec sem decomposição de tarefas em issues), aplique em vez disso um label
     `spec:<slug>` (crie com `gh label create` se faltar). Sem spec relacionada (melhoria pontual
     sem origem), não há identificação de spec a aplicar.
   - **Se não houver** remote GitHub configurado/autenticado: **pare aqui**, não crie a branch —
     peça ao usuário para configurar `git remote` + `gh auth login` antes de prosseguir. Não há
     alternativa "sem GitHub" para hotfix (diferente do PRD, que dispensa GitHub).
2. **Nomeie a branch** seguindo a tabela de prefixos de `docs/GIT-WORKFLOW.md` (seção "Mudanças no
   próprio pipeline", mesma tabela vale para hotfix de qualquer projeto): `hotfix/<slug>` se algo
   já quebrado em produção/`main` precisa de correção urgente; `fix/<slug>` se é uma correção sem
   urgência de produção, ou a melhoria pontual sem spec de origem. `<slug>` curto em kebab-case
   descrevendo a correção. Crie a branch a partir de `main` atualizada.
3. **Implemente com TDD estrito**, mesmo rigor do agente `backend-developer`/`frontend-developer`
   (teste que falha primeiro, código mínimo, refactor) — invoque o agente correspondente à trilha
   afetada (Agent tool) passando esta instrução: sem TRD/PRD desta vez, o "plano" é a descrição do
   bug/ajuste desta rodada e o escopo do passo 1. **Se a correção se aplica a múltiplos pontos de
   entrada estruturalmente equivalentes** (mesmo padrão de UI/lógica duplicado em N lugares — ex.:
   N formulários de upload usando o mesmo hook compartilhado, N validações idênticas em rotas
   irmãs), inclua explicitamente na instrução: "aplique a correção com paridade de teste em todos
   os N pontos, não só paridade de implementação" — já aconteceu de a implementação sair correta
   nos N pontos, mas só alguns ganharem teste de integração dedicado ao novo caminho, achado só
   pelo `code-reviewer` numa rodada extra de correção evitável.
   Ainda assim, apresente esse plano mínimo ao
   usuário via `AskUserQuestion` antes do primeiro commit (mesmo gate de aprovação de sempre, só
   que sobre um escopo bem menor). **Se o plano envolve mutação real de infraestrutura/config vars
   de produção ou geração deliberada de tráfego/carga** (ex.: múltiplos logins concorrentes para
   validar esgotamento de conexão), sinalize isso no próprio texto apresentado nesta
   `AskUserQuestion` — essas duas categorias são tipicamente bloqueadas pelo classificador de modo
   automático desta sessão para orquestrador e subagentes, exigindo execução manual do usuário ou
   uma regra de permissão explícita; já aconteceu de um hotfix de infra só descobrir esse bloqueio
   durante a execução, depois de comandos já terem falhado, em vez de antecipado no plano. Abra o
   PR cedo, em modo draft, com `Closes #N` referenciando a
   issue do passo 1b (sempre existe, é o gate obrigatório). **Se outra tarefa desta sessão pode
   estar ativa no mesmo
   repositório**, use isolamento de working tree (`docs/GIT-WORKFLOW.md`, seção "Isolamento de
   working tree entre agentes concorrentes").
4. **Rode a suíte completa com cobertura** (e o comando de build/empacotamento real, se a trilha
   afetada tiver um — `docs/TESTING.md`) ao final, gravando o resumo em
   `specs/<slug-da-spec-relacionada-ou-dedicada>/coverage/hotfix-<data>-<trilha>.md`, mesmo padrão
   de qualquer fatia.
5. **Decida as revisões desta rodada** — critério objetivo, não uma decisão manual reavaliada a
   cada vez:
   - **Code review: sempre.** Toda correção pontual passa por `/btt-sdd:code-review` contra o PR
     desta rodada antes do merge — sem exceção, mesmo para uma mudança de uma linha.
   - **QA: se há um critério de aceite concreto a validar.** Se a correção reafirma um
     comportamento que já tinha um critério de aceite no PRD/TRD original (ele estava quebrado, ou
     um novo critério pontual surge do próprio bug), rode `/btt-sdd:qa` contra esse critério. Uma
     correção puramente técnica sem critério de aceite de produto associado (ex.: corrigir uma
     falha de performance sem mudança de comportamento observável) pode pular o QA — registre essa
     decisão explicitamente no artefato desta rodada, nunca em silêncio.
   - **Segurança: sempre que o diff tocar qualquer item do critério objetivo de
     `docs/QUALITY-GATES.md` (seção "Segurança (`security-engineer`)")** — autenticação,
     autorização, gestão de sessão, dados pessoais/sensíveis, ou qualquer ponto de entrada
     aceitando identificador externo (e-mail, identidade SSO, token) — independente do tamanho da
     mudança. Fora desses casos, decisão do orquestrador, mas registrada no artefato desta rodada
     (nunca implícita).
   - **SRE: só se houver impacto de infraestrutura, CI/CD, ou dependência** (mudança em
     `infra/`, `.github/workflows/`, Dockerfile, ou manifesto de dependências). Uma correção
     isolada em código de aplicação sem tocar nada disso pula o SRE.
   Apresente essa decisão (quais revisões rodam e por quê) ao usuário via `AskUserQuestion` antes
   de prosseguir, oferecendo a opção de rodar uma revisão adicional mesmo que o critério acima não
   a exija.
6. **Rode cada revisão decidida no passo 5** normalmente (`/btt-sdd:code-review`, `/btt-sdd:qa`,
   `/btt-sdd:security`, `/btt-sdd:sre`), contra o PR desta rodada — cada uma edita in-place o
   artefato identificado no passo 1, com a linha `hotfix-<data>` no histórico de aprovações. Mesma
   regra de "Auto-aprovação nunca é o gate real" (skill `/btt-sdd:implement`) — nenhum agente que
   implementou a correção escreve o próprio veredito.
6b. **Antes de informar que o merge fica a critério do usuário, confirme explicitamente que toda
   revisão decidida como aplicável no passo 5 já rodou com veredito aprovado** — não confie em
   lembrar de tê-las rodado todas. Releia a decisão do passo 5 contra o estado real dos artefatos
   (`code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md`, seção "Histórico de
   aprovações por fatia", linha `hotfix-<data>`): se qualquer revisão marcada como aplicável ainda
   não tem veredito aprovado para esta rodada, **não prossiga para o passo 7** — rode a revisão
   faltante agora, ou, se por algum motivo ela não puder rodar ainda, avise isso em destaque ao
   usuário antes de qualquer menção a merge, nunca como nota de rodapé. Já aconteceu de verdade: um
   hotfix teve seu PR de código mergeado sem que SRE tivesse sido acionado — code review, QA e
   segurança rodaram normalmente, SRE simplesmente não foi lembrado antes do merge, e a lacuna só
   foi descoberta ~9 dias depois. `/btt-sdd:status` já sinaliza esse tipo de gap corretamente
   quando consultado — este passo existe para que o gap seja visto *antes* do merge, não só depois.
7. **Merge é decisão do usuário**, nunca automática — mesma regra de GitHub Flow de qualquer PR
   deste pipeline. Depois do merge, se a correção resolve algo que `docs/POST-MERGE-VALIDATION.md`
   ou um item "VALIDAR DEPOIS" esperava, feche esse ciclo (`/btt-sdd:amend`).

## Registro do processo

Ao final, resuma ao usuário: spec relacionada (ou diretório dedicado), branch/PR, quais revisões
rodaram e por quê (critério do passo 5), e onde ficou registrado o resultado — para que o próximo
`/btt-sdd:status` já reflita esta correção.

## Quando usar sem os agentes

Se o Agent tool não estiver disponível, siga o mesmo processo descrito nos agentes
`backend-developer`/`frontend-developer` para a implementação e nos agentes de revisão
correspondentes diretamente, mantendo o mesmo rigor de TDD e os mesmos critérios do passo 5.
