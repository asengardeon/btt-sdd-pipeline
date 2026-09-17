# Workflow SDD (Spec-Driven Development)

Este documento explica o funcionamento completo do pipeline de 7 etapas (+ 1 condicional) deste
repositório: por que ele existe, o que cada etapa exige/produz, e como as peças (agentes, skills,
templates) se encaixam.

## Por que Spec-Driven Development

O objetivo é que nenhuma decisão importante seja tomada implicitamente dentro do código. Cada
decisão de **o que construir** (produto), **como construir** (arquitetura) e **está correto?**
(qualidade, segurança) fica registrada em um artefato revisável, na ordem certa, antes do código
ser escrito ou aceito. Isso troca "descobrir depois que o requisito era outro" por "alinhar antes
de implementar", e troca "confiar que o dev testou/pensou em segurança" por "QA e segurança
validam objetivamente contra critérios escritos".

## Etapa 0 (condicional): Levantamento de baseline

- **Agente**: `agents/codebase-archaeologist.md`
- **Skill**: `/btt-sdd:baseline`
- **Quando roda**: só quando um TRD depende de código/sistema já existente que nenhuma spec
  anterior documentou e que não tem documentação base suficiente — cenário típico: este template
  foi adotado sobre um projeto legado. Num projeto 100% construído por este próprio pipeline
  (já documentado por construção), isso normalmente nunca dispara.
- **Entrada**: código existente insuficientemente documentado.
- **Saída**: `docs/BASELINE.md` — visão geral real do sistema, stack, estrutura, convenções
  observadas, dívida técnica identificada (nunca corrigida por este agente), lacunas de teste. Ou,
  se a documentação já é suficiente, uma constatação explícita de que nada precisa ser criado.
- **Gate de saída**: `docs/BASELINE.md` existe para a área relevante, ou a suficiência foi
  constatada explicitamente — nunca um silêncio sem conclusão.

## As 7 etapas

### 1. Produto & Design → PRD

- **Agente**: `agents/product-design.md`
- **Skill**: `/btt-sdd:prd`
- **Entrada**: um pedido de feature, em linguagem natural.
- **Saída**: `specs/<slug>/prd.md` — o quê e por quê, nunca o como técnico. Critérios de aceite
  em Gherkin, testáveis por um terceiro sem contexto adicional. Inclui "Indicadores técnicos a
  observar" (volumetria, segurança, legal) — sinalizados, não decididos — e "Ordem de valor /
  dependências entre histórias", a visão de produto de quais histórias dependem de outras. Se a
  feature tem UI, `/btt-sdd:prd` oferece ao usuário ver opções de wireframe/protótipo de baixa
  fidelidade das telas principais (via skill `design`, publicado como Artifact) antes de escrever
  as histórias em detalhe — seção "Wireframes/Protótipos de tela" do PRD.
- **Gate de saída**: aprovação explícita do usuário.

### 2. Arquitetura → TRD

- **Agente**: `agents/architect.md`
- **Skill**: `/btt-sdd:trd`
- **Entrada**: PRD aprovado (e, se aplicável, `docs/BASELINE.md` da etapa 0).
- **Saída**: `specs/<slug>/trd.md` — modelo de domínio, ports, casos de uso mapeados aos
  critérios de aceite, adapters necessários, plano de testes de alto nível, a seção "Pilares de
  engenharia de software" (performance, escalabilidade, resiliência, disponibilidade,
  observabilidade, manutenibilidade — detalhe em `docs/ENGINEERING-PILLARS.md`) respondida
  explicitamente para a feature, o "Contrato Frontend↔Backend" quando a feature tem UI (o que
  permite backend e frontend desenvolverem em paralelo), e a "Decomposição de tarefas e
  dependências" (backend/frontend/ambos, com dependência técnica explícita, e uma coluna Status
  que o pipeline mantém atualizada ponta a ponta conforme a spec avança — detalhe em
  `docs/QUALITY-GATES.md`, seção "Status de tarefas" — preferencialmente espelhada como Issues
  reais do GitHub quando há remote conectado e autenticado; a tabela do TRD sozinha é o fallback
  só quando não há GitHub configurado). ADRs em `docs/adr/` para decisões técnicas significativas.
- **Gate de saída**: aprovação explícita do usuário.

### 3. Desenvolvimento → Código + Testes (backend e/ou frontend, em paralelo quando full-stack)

- **Agentes**: `agents/backend-developer.md` e, quando a feature tem UI,
  `agents/frontend-developer.md`.
- **Skill**: `/btt-sdd:implement`
- **Entrada**: TRD aprovado.
- **Uma fatia por rodada**: se o TRD tem mais de uma fatia vertical, esta etapa (e as etapas 4-7
  seguintes) roda **uma fatia por vez**, nunca todas de uma vez — a skill escolhe a próxima fatia
  pendente e confirma com o usuário antes de montar o plano. Antes de criar a branch, confirma que
  o PR da fatia anterior já está mergeado em `main` (`docs/GIT-WORKFLOW.md`) — se não estiver,
  para e não avança.
- **Plano antes de executar**: se só uma trilha, o agente correspondente quebra sua parte da fatia
  em incrementos e pede aprovação explícita antes de escrever qualquer código (ver
  `docs/QUALITY-GATES.md`). Se as duas trilhas (full-stack), a skill `/btt-sdd:implement` monta e
  aprova **um plano combinado** com o usuário antes de invocar os dois agentes **em paralelo**,
  cada um executando sua trilha contra o contrato do TRD sem esperar pelo outro. Só depois disso
  cria a branch desta fatia (GitHub Flow, `docs/GIT-WORKFLOW.md`, uma única branch/PR por fatia,
  mesmo com as duas trilhas) e abre o PR.
- **Saída**: branch + PR desta fatia + código em `src/` (ports & adapters) e/ou `frontend/`, com
  testes em `tests/` e/ou `frontend/tests/`, produzidos via TDD (red-green-refactor), com
  cobertura ≥ 80% por pacote.
- **Gate de saída**: plano aprovado, suíte de testes passando, lint limpo, cobertura reportada por
  pacote, PR aberto, contrato respeitado por ambos os lados quando full-stack.

### 4. Revisão de código → Code review de engenheiro sênior

- **Agente**: `agents/code-reviewer.md`
- **Skill**: `/btt-sdd:code-review`
- **Entrada**: PR aberto pela etapa de implementação desta fatia + TRD.
- **Saída**: `specs/<slug>/code-review.md` — veredito sobre ports & adapters/regra da
  dependência, SOLID, clean code, qualidade dos próprios testes (não cobertura numérica),
  consistência com o contrato Frontend↔Backend quando full-stack, tratamento de erros/casos de
  borda no código, e débito técnico introduzido. Foca em **qualidade e design do código**; não
  julga critério de aceite (isso é o QA na etapa seguinte) nem segurança (isso é o
  `security-engineer`).
- **Gate de saída**: veredito geral aprovado, ou aprovado com ressalvas não-bloqueantes aceitas
  pelo usuário (senão volta para a etapa 3).

### 5. QA → Validação objetiva

- **Agente**: `agents/qa-engineer.md`
- **Skill**: `/btt-sdd:qa`
- **Entrada**: revisão de código aprovada + PRD + TRD.
- **Saída**: `specs/<slug>/qa-report.md` — veredito por critério de aceite, cobertura vs. gate de
  80%, achados de regressão e de violação de fronteira arquitetural.
- **Gate de saída**: veredito geral aprovado (senão volta para a etapa 3).

### 6. Segurança → Revisão de segurança da aplicação

- **Agente**: `agents/security-engineer.md`
- **Skill**: `/btt-sdd:security`
- **Entrada**: QA aprovado.
- **Saída**: `specs/<slug>/security-review.md` — superfície de ataque, checklist OWASP Top 10,
  gestão de segredos na aplicação, autenticação/autorização, validação de entrada, dependências
  vulneráveis, com veredito. Foca em segurança **da aplicação**; segurança **operacional/infra**
  (Docker, Terraform, segredos de pipeline) é revisada pelo `sre` na etapa seguinte, sem
  sobreposição.
- **Gate de saída**: veredito geral aprovado (senão volta para a etapa 3).

### 7. SRE → CI/CD e infraestrutura

- **Agente**: `agents/sre.md`
- **Skill**: `/btt-sdd:sre`
- **Entrada**: QA **e** segurança aprovados.
- **Plano antes de executar**: qualquer alteração real de infraestrutura (`terraform apply`) é
  apresentada como plano e só executada após aprovação explícita do usuário.
- **Saída**: `specs/<slug>/sre-review.md` — checklist de CI, CD, Docker, Terraform,
  observabilidade e proteção de `main` (GitHub Flow), com veredito.
- **Gate de saída**: aprovado (ou aprovado com ressalvas registradas). Depois disso, o merge do PR
  desta fatia para `main` é decisão do usuário — nenhum agente mergeia sozinho. Se houver fatia
  seguinte pendente na feature, ela só começa depois desse merge (`docs/GIT-WORKFLOW.md`).
- **Spec finalizada**: se a fatia aprovada nesta rodada é a última pendente da feature,
  `/btt-sdd:sre` também aciona `tech-writer` automaticamente para atualizar a documentação do
  repositório (README, `docs/`, ADRs) refletindo a feature completa, antes de informar o usuário
  sobre o merge. Depois desse merge, `/btt-sdd:implement` conduz o teste geral obrigatório de fim de
  spec contra produção real (`docs/POST-MERGE-VALIDATION.md`) — a spec só é considerada concluída
  com esse teste feito, não só com o merge.
- **Retrospectiva da fatia (toda fatia, não só a última)**: antes de informar o usuário sobre o
  merge, `/btt-sdd:sre` também avalia a execução da rodada e abre issues de melhoria de fluxo/
  performance/custo de token e de aprendizado generalizável em `asengardeon/btt-sdd-pipeline` — o
  repositório de origem do plugin, sempre esse, independente de qual projeto está rodando o
  pipeline (`skills/sre/SKILL.md`, seção "Retrospectiva da fatia"). Não é opcional nem
  condicionado a achar algo — "nenhuma sugestão concreta desta fatia" é uma conclusão válida da
  avaliação, pular a própria avaliação não é.

## Governança de decisão (vale para todas as etapas, incluindo a condicional)

Detalhe completo em `docs/QUALITY-GATES.md`. Resumo: nenhum agente faz suposição silenciosa —
toda ambiguidade vira pergunta ao usuário, com **"VALIDAR DEPOIS"** sempre disponível como opção
quando o usuário não souber responder agora (o item fica registrado na seção "Pendências de
validação" do artefato). Nenhuma ação ou pergunta se repete mais de 3 vezes sem escalar. Use
`/btt-sdd:pending` para ver todos os itens VALIDAR DEPOIS em aberto em qualquer momento. Quem
orquestra qualquer etapa (você, seguindo `/btt-sdd:implement` ou outra skill) prefere delegar
investigação de causa raiz somente-leitura (ler vários arquivos, histórico de Git, logs) a uma
sub-tarefa isolada que devolva só a conclusão, em vez de reter esse conteúdo no próprio contexto
de orquestração, quando ele não precisa continuar disponível depois da decisão tomada. Todo
feedback real sobre o próprio plugin — generalizável, não específico deste projeto — vira issue em
`asengardeon/btt-sdd-pipeline` assim que fica claro, em qualquer momento de qualquer sessão, não
só ao final de uma fatia.

## Utilitários: `/btt-sdd:status` e `/btt-sdd:pending`

`/btt-sdd:status` não aciona agente — lê `specs/` e reporta em que etapa cada feature está, qual o
próximo comando a rodar, quantas pendências VALIDAR DEPOIS existem e se alguma etapa foi marcada
"requer revalidação" por uma emenda. `/btt-sdd:pending` lista o detalhe dos itens VALIDAR DEPOIS em
todas as features (e em `docs/BASELINE.md`, quando existir). Use a qualquer momento para se
orientar.

## Utilitário: `/btt-sdd:project-conventions`

Sem posição fixa numa etapa, no mesmo espírito de `/btt-sdd:docs`. Aciona `codebase-archaeologist`
numa responsabilidade separada da Etapa 0: em vez de documentar o sistema (`docs/BASELINE.md`),
documenta como **este projeto** particulariza o próprio pipeline — modelo de workflow de Git,
estrutura de pastas, nomenclatura — em relação ao padrão genérico, produzindo/atualizando
`docs/PROJECT-CONVENTIONS.md` só com as divergências reais. Roda sozinho a qualquer momento,
automaticamente ao final de `/btt-sdd:create-project`, ou de carona numa rodada de
`/btt-sdd:baseline` que já está inspecionando o projeto.

## Flexibilidade de entrada e uso em qualquer projeto

Os agentes e skills deste pipeline estão instalados globalmente (ver "Distribuição global" em
`CLAUDE.md`) — funcionam em qualquer projeto, não só neste repositório, e não dependem de um
artefato de uma etapa anterior já existir na convenção padrão para começar: skills como
`/btt-sdd:prd` e `/btt-sdd:trd` aceitam um caminho de arquivo explícito como entrada (ex.: `/btt-sdd:trd
caminho/para/spec.md`) além da convenção `specs/<slug>/`. Para começar um projeto do zero num
diretório novo, use `/create-project`.

## Regra de ouro

Cada etapa **exige o artefato aprovado** da etapa anterior como pré-condição. Um agente que não
encontra o artefato de entrada não improvisa um — ele para e diz ao usuário qual comando rodar
antes. Isso é o que torna o pipeline confiável: pular etapa nunca é "mais rápido", é retrabalho
disfarçado.

## Ciclo de feedback

Se a revisão de código reprova, a feature volta para `/btt-sdd:implement` com os achados específicos.
Se o QA reprova, a feature volta para `/btt-sdd:implement` com achados específicos. Se a segurança
reprova, também volta para `/btt-sdd:implement` (com os achados de segurança). Se o SRE reprova (ou
aprova com ressalvas bloqueantes), os itens voltam para quem for responsável — pode ser
`backend-developer`/`frontend-developer` (ex.: falta observabilidade no código) ou ajuste direto
do próprio `sre` em `infra/`. O PRD e o TRD só são reabertos se a causa raiz for de requisito ou
de design.

## Emenda sem reiniciar: `/btt-sdd:amend`

Mudar uma decisão **já aprovada** (não uma reprovação — uma mudança de ideia, ou a resolução de um
item VALIDAR DEPOIS) não reinicia o pipeline. `/btt-sdd:amend` edita o artefato in-place, registra a
mudança no "Log de revisões" dele, e marca só as etapas *posteriores* realmente afetadas como
"requer revalidação" — etapas anteriores aprovadas continuam válidas. Ex.: mudar um detalhe de
texto no PRD que não muda critério de aceite não invalida o TRD; mudar um critério de aceite
invalida TRD, implementação, revisão de código, QA e segurança, mas não obriga a refazer a
conversa toda do PRD.

## Correção pontual pós-merge: `/btt-sdd:hotfix`

Um bug encontrado em produção (ou numa validação manual) depois que a spec relacionada já
concluiu as 7 etapas e foi mergeada — ou uma melhoria pontual sem spec de origem nenhuma — não
reabre o pipeline completo do zero. `/btt-sdd:hotfix` formaliza esse caminho fora de banda: sem
PRD/TRD, mas com o mesmo rigor de TDD, branch/PR (GitHub Flow, `docs/GIT-WORKFLOW.md`) e as
revisões que se aplicarem — code review sempre; QA se há critério de aceite concreto a validar;
segurança sempre que o diff tocar autenticação, autorização, sessão, dado sensível, ou entrada de
identificador externo (critério objetivo em `docs/QUALITY-GATES.md`, seção "Segurança"); SRE só
com impacto de infraestrutura/CI/dependência. O resultado é registrado na spec relacionada
(in-place, linha `hotfix-<data>` no histórico de aprovações) ou num diretório de spec dedicado sem
`prd.md`/`trd.md` quando não há spec de origem. Não confunda com uma feature nova pequena — se o
escopo crescer (critério de aceite novo, decisão de arquitetura relevante), migre para `/btt-sdd:prd`.

## GitHub Flow no pipeline

Detalhe completo em `docs/GIT-WORKFLOW.md`. Resumo: a etapa 0 e o PRD/TRD não têm branch (são
documentos). Cada **fatia vertical** do TRD é sua própria branch/PR: `/btt-sdd:implement` cria a
branch da fatia (só depois do PR da fatia anterior já mergeado) e abre PR draft cedo. Revisão de
código, QA, segurança e SRE revisam contra o PR dessa fatia. Merge para `main` só acontece depois
de revisão de código, QA, segurança e SRE aprovados **para aquela fatia**, é uma decisão do
usuário (nenhum agente mergeia sozinho), e dispara o CD — liberando a fatia seguinte para começar.

## Primeira feature deste projeto

`/create-project` já criou o primeiro PRD (`specs/0001-<slug>/prd.md`) a partir dos requisitos
que você deu. Aprove-o e rode `/btt-sdd:trd` para seguir o pipeline a partir daqui.
