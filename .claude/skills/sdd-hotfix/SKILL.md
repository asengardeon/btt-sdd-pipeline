---
name: sdd-hotfix
description: Correção pontual pós-merge, fora do ciclo normal de fatias do pipeline SDD. Use quando um bug é encontrado em produção (ou numa validação manual) depois que a spec relacionada já foi mergeada, ou para uma melhoria pontual sem spec de origem — sem PRD/TRD, mas ainda com TDD e as revisões relevantes (code review sempre; QA/segurança/SRE conforme o critério desta skill).
---

# /sdd-hotfix

Formaliza o processo de **correção pontual pós-merge**: um bug encontrado em produção (ou numa
validação manual) depois que a spec relacionada já concluiu o pipeline e foi mergeada, ou uma
melhoria pontual sem spec de origem nenhuma. Diferente das 7 etapas normais (`docs/SDD-WORKFLOW.md`),
esta skill **não gera PRD nem TRD** — o pedido já é concreto o suficiente (um bug específico, um
ajuste pontual) para não justificar o levantamento de produto/arquitetura completo. Isso não é uma
saída para pular rigor: TDD, code review, e as revisões que se aplicarem continuam obrigatórias.

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Quando usar

- Um bug foi encontrado em produção (ou durante `docs/POST-MERGE-VALIDATION.md`) numa feature cuja
  spec já está com todas as fatias mergeadas — não é o caso de "fatia ainda em andamento" (isso
  volta para `/sdd-implement` normalmente, achados de revisão da própria fatia).
- Uma melhoria pontual e de baixo risco é pedida sem nenhuma spec de origem (nunca passou por
  `/sdd-prd`).
- **Não use** para uma mudança que na prática é uma feature nova (critério de aceite novo,
  decisão de arquitetura relevante, mais de uma fatia de esforço) — isso é `/sdd-prd` normalmente,
  mesmo que o pedido pareça pequeno à primeira vista. Se a correção crescer em escopo/risco no meio
  da execução desta skill, pare e migre para o fluxo completo em vez de continuar aqui (mesmo
  espírito de `specs/_template/oneshot.template.md`).

## Passos

1. **Identifique a spec relacionada, se houver.** Se o bug está numa área de código que uma spec
   existente em `specs/` introduziu ou alterou por último, essa é a spec relacionada — os
   artefatos desta rodada (`code-review.md`/`ux-review.md`/`qa-report.md`/`security-review.md`/
   `sre-review.md`) são editados **in-place** nela, com uma linha nova na respectiva "Histórico de
   aprovações por fatia" usando `hotfix-<data>` (ex.: `hotfix-2026-09-01`) no lugar do
   identificador de fatia (`F-N`). Se não há nenhuma spec relacionada (melhoria pontual sem origem), crie um diretório
   dedicado `specs/<NNNN>-<slug-curto>/` (próximo número sequencial livre em `specs/`) contendo só
   os artefatos de revisão que se aplicarem — sem `prd.md`/`trd.md`.
1b. **Gate obrigatório: confirme/crie a Issue GitHub deste hotfix antes de criar a branch.**
   Verifique remote GitHub configurado e autenticado (`git remote -v`, `gh auth status`).
   - **Se houver**: se o bug/ajuste já tem uma issue aberta (o usuário citou o número, ou ela
     existe no repositório), use-a; senão crie uma via `gh issue create` descrevendo o
     bug/ajuste, com o label de tipo apropriado (`bug` ou `enhancement`). Nenhum hotfix começa
     sem essa issue — sem exceção, mesmo para uma correção de uma linha. **Se o passo 1 identificou
     uma spec relacionada**, identifique essa issue estruturadamente contra ela
     (`docs/gates/trd.md`): reaproveite o milestone da spec se ele já existir (`gh
     api repos/<owner>/<repo>/milestones` filtrando por título `<slug>` — o mesmo milestone que
     `architect` cria por spec, `.claude/agents/architect.md`); se ainda não existir nenhum
     milestone para essa spec/projeto (spec sem decomposição de tarefas em issues), aplique em vez
     disso um label `spec:<slug>` (crie com `gh label create` se faltar). Sem spec relacionada
     (melhoria pontual sem origem), não há identificação de spec a aplicar.
   - **Se não houver** remote GitHub configurado/autenticado: **pare aqui**, não crie a branch —
     peça ao usuário para configurar `git remote` + `gh auth login` antes de prosseguir. Não há
     alternativa "sem GitHub" para hotfix (diferente do PRD, que dispensa GitHub).
2. **Nomeie a branch** seguindo a tabela de prefixos de `docs/GIT-WORKFLOW.md` (seção "Mudanças no
   próprio pipeline", mesma tabela vale para hotfix de qualquer projeto): `hotfix/<slug>` se algo
   já quebrado em produção/`main` precisa de correção urgente; `fix/<slug>` se é uma correção sem
   urgência de produção, ou a melhoria pontual sem spec de origem. `<slug>` curto em kebab-case
   descrevendo a correção. Crie a branch a partir de `main` atualizada.
3. **Implemente com TDD estrito**, mesmo rigor de `.claude/agents/backend-developer.md`/
   `.claude/agents/frontend-developer.md` (teste que falha primeiro, código mínimo, refactor) —
   invoque o agente correspondente à trilha afetada (Agent tool) passando esta instrução: sem
   TRD/PRD desta vez, o "plano" é a descrição do bug/ajuste desta rodada e o escopo do passo 1.
   **Se a correção se aplica a múltiplos pontos de entrada estruturalmente equivalentes** (mesmo
   padrão de UI/lógica duplicado em N lugares — ex.: N formulários de upload usando o mesmo hook
   compartilhado, N validações idênticas em rotas irmãs), inclua explicitamente na instrução:
   "aplique a correção com paridade de teste em todos os N pontos, não só paridade de
   implementação" — já aconteceu de a implementação sair correta nos N pontos, mas só alguns
   ganharem teste de integração dedicado ao novo caminho, achado só pelo `code-reviewer` numa
   rodada extra de correção evitável.
   Ainda assim, apresente esse plano mínimo ao usuário via `AskUserQuestion` antes do primeiro
   commit (mesmo gate de aprovação de sempre, só que sobre um escopo bem menor). **Se o plano
   envolve mutação real de infraestrutura/config vars de produção ou geração deliberada de
   tráfego/carga** (ex.: múltiplos logins concorrentes para validar esgotamento de conexão),
   sinalize isso no próprio texto apresentado nesta `AskUserQuestion` — essas duas categorias são
   tipicamente bloqueadas pelo classificador de modo automático desta sessão para orquestrador e
   subagentes, exigindo execução manual do usuário ou uma regra de permissão explícita; já
   aconteceu de um hotfix de infra só descobrir esse bloqueio durante a execução, depois de
   comandos já terem falhado, em vez de antecipado no plano. Abra o PR cedo,
   em modo draft, com `Closes #N` referenciando a issue do passo 1b (sempre existe, é o gate
   obrigatório). **Se outra tarefa
   desta sessão pode estar ativa no mesmo repositório**, use isolamento de working tree
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes").
3a. **Quando a causa raiz for comportamento de um sistema externo** (DOM de terceiro, API de
   parceiro, SDK fechado), **a sonda que provou a causa é a especificação executável da correção —
   não a descrição dela.** Registre, no artefato desta rodada **e no corpo da instrução passada ao
   agente**, a **sequência exata** que a sonda executou: cada passo, na ordem, com os intervalos
   medidos entre eles ("esperar 250 ms antes de reler o campo", não "reler depois de preencher").
   Exija explicitamente que a implementação **e** o knob de mock que a exercita reproduzam essa
   sequência passo a passo, com os mesmos intervalos — não uma paráfrase dela. Descrever a sonda em
   prosa perde justamente o detalhe que a faz funcionar: já aconteceu de verdade, e custou uma
   rodada inteira de implementação evitável. A sonda esperava ~250 ms entre preencher o campo e
   reler o valor, e era esse intervalo que fazia a correção funcionar (a hidratação do framework da
   página reescrevia o input algumas centenas de milissegundos depois). A instrução virou
   "preencher → reler → repetir", o intervalo não chegou ao código, a implementação releu colada na
   escrita — medindo o DOM **antes** do efeito que queria detectar — e passou nos testes.
3b. **Registre cada rodada desta skill em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir, como qualquer outra etapa). Esta
   skill invoca `backend-developer`/`frontend-developer` **direto**, contornando `/sdd-implement` — e
   com ele a instrução de registro que vive lá (passos 3b e 5a). Sem este passo, a série de hotfix
   fica sistematicamente incompleta, e é justamente ela que a retrospectiva de fatia lê para achar
   etapa anormalmente lenta. Uma linha (etapa, agente, `hotfix-<data>` na coluna Fatia, duração) para
   **cada**:
   - **rodada de implementação** — uma linha por invocação de agente, não uma linha pelo hotfix
     inteiro; três rodadas de correção são três linhas;
   - **validação ao vivo** do passo 4b, inclusive as que reprovaram;
   - **diagnóstico de causa raiz conduzido por você mesmo**, sem invocar agente — `orquestrador (sem
     agente)` é um valor legítimo da coluna Agente, com seção própria no template
     (`specs/_template/timing-log.template.md`, seção "Trabalho conduzido pelo orquestrador (sem
     agente)"). Se a cópia de `timing-log.md` já existente no projeto afirmar que o template "não tem
     lugar para tempo de orquestrador", é a cópia que está desatualizada em relação ao template desta
     instalação — vale o template (`docs/SKILL-PREAMBLE.md`), e a nota obsoleta pode ser corrigida na
     mesma rodada.
   Já aconteceu de verdade: um hotfix com **seis** rodadas de trabalho — cinco de implementação, três
   validações ao vivo contra produção, um diagnóstico de causa raiz do orquestrador e uma rodada de
   SRE — deixou exatamente **duas** linhas no `timing-log.md` (code review e segurança). Quem lesse a
   série concluiria que o hotfix custou ~71 minutos. As rodadas anteriores tinham sido registradas por
   zelo do orquestrador, não por instrução.
4. **Rode a suíte completa com cobertura** (e o comando de build/empacotamento real, se a trilha
   afetada tiver um — `docs/TESTING.md`) ao final, gravando o resumo em
   `specs/<slug-da-spec-relacionada-ou-dedicada>/coverage/hotfix-<data>-<trilha>.md`, mesmo padrão
   de qualquer fatia.
   **Toda rodada que regrava esse arquivo atualiza o campo `Commit` com o commit da própria rodada**,
   nunca herda o da primeira (`specs/_template/coverage-summary.template.md`) — é desse campo que a
   etapa seguinte decide se pode reaproveitar a evidência em vez de rodar a suíte de novo, e num
   hotfix com várias rodadas de correção no mesmo PR o campo desatualizado faz uma execução velha
   passar por fresca. Já aconteceu de verdade: após três rodadas, o cabeçalho ainda apontava para o
   commit da rodada 1, pego por uma rodada de code review. **E a base de qualquer diff desta rodada é
   calculada** (`git merge-base HEAD main`), nunca lida da coluna `Commit` de uma tabela de histórico:
   com *squash merge*, o SHA registrado lá deixa de ser ancestral de `main`, e um revisor que confiar
   nele revisa o diff errado.
4a. **Todo valor medido ao vivo é substituído por equivalente não atribuível antes de entrar em
   qualquer lugar — inclusive na instrução que você passa ao agente.** A medição com dado real é
   legítima (foi ela que provou o defeito), mas o valor medido não viaja cru: substitua no momento em
   que ele sai da medição, preservando a **assinatura do incidente** (contagem de dígitos, zeros à
   esquerda, máscara aplicada, qual validação ele passa ou falha) — `docs/TESTING.md`, seção "Valor
   medido ao vivo entra no repositório já substituído por equivalente não atribuível". Isso vale para
   o artefato do passo 4b, para os testes, para o knob de mock do passo 3a, para comentário/XML doc,
   e **principalmente para o corpo da instrução passada ao `backend-developer`/`frontend-developer`**
   — foi por ali que, numa rodada real, CPF com dígitos verificadores válidos, telefone, nome e
   e-mail reais chegaram a seis arquivos do repositório, dois deles de código de produção, custando
   uma rodada inteira só para redigir.
4b. **Se o defeito só era observável contra o sistema real, revalide ao vivo antes de acionar
   qualquer revisão — com artefato próprio, nunca como relato em comentário de PR.** Repita a
   medição original (a sequência do passo 3a) contra o sistema real e grave o resultado em
   `specs/<slug-da-spec-relacionada-ou-dedicada>/coverage/hotfix-<data>-validacao-ao-vivo.md`, uma
   seção por rodada, append-only: sequência executada, o que foi observado **antes** da correção, o
   que foi observado **depois**, e o veredito (`defeito reproduzido` / `não reproduzido`). **Suíte
   verde não substitui esta medição** — o cenário que originou este passo é exatamente o de uma
   suíte verde sobre código que media o DOM antes do efeito. Enquanto o veredito não for `não
   reproduzido`, **não prossiga para o passo 5**: mandar para revisão um código que ainda não
   corrige o defeito gasta a cadeia inteira de revisão numa rodada que vai ser refeita — já
   aconteceu, três rodadas de implementação até a validação ao vivo passar. Isto é de rodada de
   hotfix e **não substitui** o teste geral de fim de spec de `docs/POST-MERGE-VALIDATION.md`, que
   continua valendo depois do merge.
   Cada execução desta validação — inclusive as que reprovaram — rende a sua própria linha no
   `timing-log.md` (passo 3b).
5. **Decida as revisões desta rodada** — critério objetivo, não uma decisão manual reavaliada a
   cada vez:
   - **Code review: sempre.** Toda correção pontual passa por `/sdd-code-review` contra o PR desta
     rodada antes do merge — sem exceção, mesmo para uma mudança de uma linha.
   - **QA: se há um critério de aceite concreto a validar.** Se a correção reafirma um
     comportamento que já tinha um critério de aceite no PRD/TRD original (ele estava quebrado, ou
     um novo critério pontual surge do próprio bug), rode `/sdd-qa` contra esse critério. Uma
     correção puramente técnica sem critério de aceite de produto associado (ex.: corrigir uma
     falha de performance sem mudança de comportamento observável) pode pular o QA — registre essa
     decisão **com o heading padronizado `## Decisão: QA pulado (justificado)`** no
     `qa-report.md` desta rodada (crie o arquivo a partir do template se ainda não existir, só com
     essa seção — não é um relatório de execução de QA), com a justificativa completa logo abaixo.
     Nunca registre essa decisão em texto livre sem esse heading — é o que permite a
     `/sdd-status`/`/sdd-pending` (`skills/status/scripts/sdd-status.sh`/`.ps1`) reconhecerem isso
     como um estado terminal válido em vez de "veredito não identificado", evitando que o usuário
     seja questionado à toa sobre algo já decidido e justificado.
   - **UX/Usabilidade: sempre que o diff alterar uma tela/fluxo com superfície de UI perceptível
     pelo usuário final** (layout, navegação, visibilidade condicional de controles, estado
     vazio/erro, conteúdo de mídia) — roda `/sdd-ux-review` contra o PR desta rodada. Uma correção
     puramente de backend/infra sem nenhuma tela afetada pula esta etapa, registrando a decisão no
     mesmo padrão já usado para QA pulado (heading padronizado `## Decisão: UX review pulado
     (justificado)`, com a justificativa completa) no `ux-review.md` desta rodada.
   - **Segurança: sempre que o diff tocar qualquer item do critério objetivo de
     `docs/gates/seguranca.md`** — autenticação,
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
6. **Rode cada revisão decidida no passo 5** normalmente (`/sdd-code-review`, `/sdd-ux-review`,
   `/sdd-qa`, `/sdd-security`, `/sdd-sre`), contra o PR desta rodada — cada uma edita in-place o artefato
   identificado no passo 1, com a linha `hotfix-<data>` no histórico de aprovações. Mesma regra de
   "Auto-aprovação nunca é o gate real" (`.claude/skills/sdd-implement/SKILL.md`) — nenhum agente
   que implementou a correção escreve o próprio veredito.
   Cada skill de revisão registra a própria invocação no `timing-log.md`; antes de seguir para o
   passo 6b, confirme que isso aconteceu de fato para esta rodada e acrescente a linha que faltar
   (passo 3b) — um hotfix em que só as revisões aparecem no log é o sintoma do problema que aquele
   passo existe para evitar.
6b. **Antes de informar que o merge fica a critério do usuário, confirme explicitamente que toda
   revisão decidida como aplicável no passo 5 já rodou com veredito aprovado** — não confie em
   lembrar de tê-las rodado todas. Releia a decisão do passo 5 contra o estado real dos artefatos
   (`code-review.md`/`ux-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md`, seção
   "Histórico de aprovações por fatia", linha `hotfix-<data>`): se qualquer revisão marcada como aplicável ainda
   não tem veredito aprovado para esta rodada, **não prossiga para o passo 7** — rode a revisão
   faltante agora, ou, se por algum motivo ela não puder rodar ainda, avise isso em destaque ao
   usuário antes de qualquer menção a merge, nunca como nota de rodapé. Já aconteceu de verdade: um
   hotfix teve seu PR de código mergeado sem que SRE tivesse sido acionado — code review, QA e
   segurança rodaram normalmente, SRE simplesmente não foi lembrado antes do merge, e a lacuna só
   foi descoberta ~9 dias depois. `/sdd-status` já sinaliza esse tipo de gap corretamente quando
   consultado — este passo existe para que o gap seja visto *antes* do merge, não só depois.
7. **Merge é decisão do usuário**, nunca automática — mesma regra de GitHub Flow de qualquer PR
   deste pipeline. Depois do merge, **confirme que a(s) issue(s) do PR fecharam de fato** (`gh pr
   view <PR> --json closingIssuesReferences`) e feche à mão, citando o PR, qualquer uma que tenha
   sobrado: o `Closes` pode ter falhado silenciosamente se o corpo do PR usou a lista com vírgulas
   simples (`Closes #A, #B`) em vez da palavra-chave repetida (`docs/GIT-WORKFLOW.md`, regras 5b e
   5c). Depois disso, se a correção resolve algo que `docs/POST-MERGE-VALIDATION.md` ou um item
   "VALIDAR DEPOIS" esperava, feche esse ciclo (`/sdd-amend`).

## Registro do processo

Ao final, resuma ao usuário: spec relacionada (ou diretório dedicado), branch/PR, quais revisões
rodaram e por quê (critério do passo 5), e onde ficou registrado o resultado — para que o próximo
`/sdd-status` já reflita esta correção.

## Quando usar sem os agentes

Se o Agent tool não estiver disponível, siga `.claude/agents/backend-developer.md`/
`.claude/agents/frontend-developer.md` para a implementação e os agentes de revisão
correspondentes diretamente, mantendo o mesmo rigor de TDD e os mesmos critérios do passo 5.
