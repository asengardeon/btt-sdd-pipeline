# Guia de arquivos — o que cada arquivo/pasta faz

Referência item a item do repositório. Para o *porquê* das decisões, veja `docs/ARCHITECTURE.md`
e `docs/SDD-WORKFLOW.md`; este documento é sobre *o que cada coisa é*.

## Raiz

- **`CLAUDE.md`** — arquivo que o Claude Code carrega automaticamente no início de toda sessão
  neste repositório. É o ponto de entrada: resume o pipeline, os princípios e onde encontrar
  cada detalhe. Se você só vai ler um arquivo, é este.
- **`README.md`** — introdução para humanos (não é carregado automaticamente pelo Claude Code):
  o que é o repositório e como começar a usá-lo.
- **`.claude-plugin/marketplace.json`** — manifesto que faz este repositório funcionar como um
  marketplace local de plugins do Claude Code, listando `plugins/btt-sdd` como plugin instalável
  (`claude plugin marketplace add` + `claude plugin install btt-sdd@projeto-base-ia`).

## `plugins/btt-sdd/` — o pipeline empacotado como plugin instalável

Mesmo pipeline de `.claude/agents/`/`.claude/skills/` (ver seções abaixo), empacotado no formato
de plugin do Claude Code (`.claude-plugin/plugin.json` + `agents/` + `skills/`, incluindo
`create-project/scaffold/`). É uma **cópia própria**, não um link para `.claude/` — necessária
porque comandos instalados via plugin ganham o namespace `btt-sdd:` (`/btt-sdd:sdd-trd`, não
`/sdd-trd`), então toda referência interna a um comando `/sdd-*` dentro dos arquivos do plugin já
vem com esse prefixo. `plugins/btt-sdd/README.md` documenta o processo de replicar uma edição de
`.claude/agents/*.md`/`.claude/skills/*` para cá quando necessário. Instalação local testada e
confirmada funcionando (ver `CLAUDE.md`, seção "Distribuição global").

## `.claude/agents/` — os agentes do pipeline (6 + 1 condicional)

Cada arquivo `.md` aqui define um **subagente** invocável pela ferramenta Agent/Task do Claude
Code. O nome do arquivo (sem `.md`) é o `subagent_type`. O frontmatter YAML no topo declara nome,
descrição (usada para o Claude decidir quando invocar) e quais ferramentas o agente pode usar; o
corpo do arquivo é o "prompt de sistema" daquele agente — seu papel, regras e processo.

Todos têm `AskUserQuestion` — é o mecanismo pelo qual param e perguntam ao usuário de verdade em
vez de assumir (regra de governança em `docs/QUALITY-GATES.md`), sempre oferecendo "VALIDAR
DEPOIS" como opção quando cabível.

- **`codebase-archaeologist.md`** — etapa **condicional** (etapa 0): produz `docs/BASELINE.md`
  quando falta documentação base sobre código já existente. Tem `Bash` para ler histórico/rodar
  testes existentes sem alterá-los, e `Write`/`Edit` só para documentação — nunca corrige/refatora
  código.
- **`product-design.md`** — gera o PRD a partir de um pedido, incluindo a ordem de valor entre
  histórias. Não roda comandos (sem acesso a `Bash`) porque essa etapa é puramente de produto.
- **`architect.md`** — gera o TRD a partir do PRD aprovado (e de `docs/BASELINE.md`, quando
  existir), incluindo a decisão de stack tecnológica (reaproveitando `docs/STACK.md` ou
  `~/.claude/stack-defaults.md` quando existirem, perguntando só se nenhum dos dois existir), os
  pilares de engenharia (`docs/ENGINEERING-PILLARS.md`), o contrato frontend↔backend e a
  decomposição de tarefas com dependências. Tem `Bash` para checar `docs/STACK.md`/remote
  GitHub/`gh auth status` e, com confirmação do usuário, espelhar tarefas como GitHub Issues.
- **`backend-developer.md`** — implementa a trilha de backend via TDD a partir do TRD, em `src/`,
  dentro de uma branch GitHub Flow. Tem acesso a `Bash` porque precisa rodar testes/lint/git
  durante o ciclo red-green-refactor. Apresenta um plano de implementação e pede aprovação antes
  do primeiro commit (a menos que orquestrado por `/sdd-implement` com plano já aprovado).
- **`frontend-developer.md`** — implementa a trilha de frontend via TDD a partir do TRD, em
  `frontend/`, contra o contrato definido pelo `architect`. Mesmo padrão de `Bash` e aprovação de
  plano de `backend-developer`. Quando a feature é full-stack, os dois rodam em paralelo,
  orquestrados por `/sdd-implement`.
- **`qa-engineer.md`** — valida a implementação contra PRD/TRD e o PR aberto. Tem `Bash` para
  rodar a suíte de testes e o relatório de cobertura, e `Write`/`Edit` só para o próprio
  `qa-report.md` — QA não corrige código de produção, reporta.
- **`security-engineer.md`** — revisa segurança da aplicação (OWASP, segredos, autenticação/
  autorização, validação de entrada, dependências) depois do QA. Mesma lógica de `Write`/`Edit`
  restrito ao próprio `security-review.md` — não corrige código, reporta.
- **`sre.md`** — valida/ajusta CI/CD e infraestrutura, depois de QA e segurança aprovados. Tem
  `Bash`, `Write` e `Edit` porque pode precisar ajustar arquivos de `infra/` e
  `.github/workflows/` diretamente; qualquer alteração real de infraestrutura passa por um plano
  aprovado antes de executar.

## `.claude/skills/` — os comandos que acionam o pipeline

Cada subpasta é uma skill invocável como slash command (`/nome-da-pasta`). O arquivo
`SKILL.md` dentro dela contém as instruções que o Claude segue quando o comando é chamado —
tipicamente: validar pré-condição, invocar o agente correspondente, e comunicar o resultado.

- **`sdd-baseline/`** → `/sdd-baseline` — aciona `codebase-archaeologist` (condicional).
- **`sdd-prd/`** → `/sdd-prd` — aciona `product-design`. Aceita um caminho de arquivo explícito
  como entrada, além de texto livre.
- **`sdd-trd/`** → `/sdd-trd` — aciona `architect`. Aceita um caminho de arquivo explícito como
  PRD de entrada, além da convenção `specs/<slug>/prd.md`.
- **`sdd-implement/`** → `/sdd-implement` — aciona `backend-developer` e/ou `frontend-developer`;
  quando os dois, orquestra um plano combinado e os invoca em paralelo.
- **`sdd-qa/`** → `/sdd-qa` — aciona `qa-engineer`.
- **`sdd-security/`** → `/sdd-security` — aciona `security-engineer`.
- **`sdd-sre/`** → `/sdd-sre` — aciona `sre`.
- **`sdd-status/`** → `/sdd-status` — utilitário de leitura, não aciona nenhum agente; mostra em
  que etapa cada feature de `specs/` está, quantas pendências VALIDAR DEPOIS tem, e se alguma
  etapa foi marcada "requer revalidação" por uma emenda.
- **`sdd-amend/`** → `/sdd-amend` — utilitário de edição, não aciona nenhum agente; emenda um
  artefato já aprovado in-place e marca só as etapas posteriores realmente afetadas como "requer
  revalidação", sem reiniciar o pipeline da primeira etapa.
- **`sdd-pending/`** → `/sdd-pending` — utilitário de leitura, não aciona nenhum agente; lista
  todos os itens "VALIDAR DEPOIS" em aberto em todas as features.
- **`create-project/`** → `/create-project` — skill global (ver "Distribuição global" em
  `CLAUDE.md`): pergunta nome, diretório e requisitos, cria um projeto novo em diretório separado
  (fora deste repositório), copia o conteúdo genérico de `create-project/scaffold/` para lá, e
  inicia o pipeline com o primeiro PRD. Não aciona um subagente próprio — usa o processo do
  `product-design` diretamente. `create-project/scaffold/` é uma cópia genérica (sem menção ao
  exemplo Python deste repo) dos arquivos estruturais stack-agnósticos — não inclui `infra/`,
  `.github/workflows/`, `src/`/`tests/`, que dependem da stack decidida só no TRD.

## `docs/` — documentação de referência

- **`ARCHITECTURE.md`** — explica ports & adapters, SOLID e clean code, e como mapeiam para
  `src/`.
- **`SDD-WORKFLOW.md`** — explica o pipeline de 6 etapas (+ 1 condicional) em detalhe:
  entrada/saída/gate de cada uma.
- **`TESTING.md`** — explica TDD, a pirâmide de testes e o gate de cobertura de 80%.
- **`ENGINEERING-PILLARS.md`** — explica os pilares de engenharia (performance, escalabilidade,
  resiliência, disponibilidade, observabilidade, manutenibilidade) que o `architect` precisa
  endereçar explicitamente na seção 10 do TRD.
- **`QUALITY-GATES.md`** — checklist único e não-negociável dos gates críticos do pipeline
  (governança de decisão, baseline, PRD, TRD, implementação, QA, segurança, SRE, merge) —
  referência central citada por todos os agentes, para não duplicar a lista em cada um deles.
- **`GIT-WORKFLOW.md`** — GitHub Flow aplicado ao pipeline: convenção de branch, PR, proteção de
  `main`, e como cada etapa do SDD se relaciona com branch/PR/merge.
- **`BASELINE.md`** — **gerado condicionalmente** pelo `codebase-archaeologist` (não existe por
  padrão neste repositório, já que ele nasceu 100% documentado pelo próprio pipeline). Quando
  existe, descreve um sistema/código pré-existente "como é" (as-is), não como deveria ser.
- **`STACK.md`** — criado/atualizado pelo `architect` na primeira vez que a stack tecnológica é
  decidida neste repositório (etapa 2 do processo em `.claude/agents/architect.md`) — não é criado
  pelo `/create-project`, sua ausência é o próprio sinal de "stack ainda não decidida". Existe
  neste repositório desde o exemplo `0001-example-task-management` (Python) e serve de fonte para
  qualquer feature nova aqui não precisar perguntar de novo.
- **`FILE-GUIDE.md`** — este arquivo.
- **`adr/`** — Architecture Decision Records. Cada arquivo numerado registra uma decisão técnica
  significativa (contexto, opções consideradas, decisão, consequências). `0001-...md` é o próprio
  ADR que estabelece a convenção de registrar ADRs — leia-o como modelo antes de criar o próximo.

## `specs/` — os artefatos do pipeline SDD, um diretório por feature

- **`_template/`** — os modelos (`prd.template.md`, `trd.template.md`, `qa-report.template.md`,
  `security-review.template.md`, `sre-review.template.md`) que os agentes preenchem. Não é uma
  feature, é a fôrma usada por todas. Todos têm uma seção "Pendências de validação (VALIDAR
  DEPOIS)" e um "Log de revisões" (preenchido pelo `/sdd-amend`); o PRD também tem "Indicadores
  técnicos a observar" (volumetria, segurança, legal) e "Ordem de valor / dependências entre
  histórias"; o TRD tem "Pilares de engenharia de software", "Contrato Frontend↔Backend (API)",
  "Decomposição de tarefas e dependências" e "Controle de versão (GitHub Flow)" (branch/PR).
- **`0001-example-task-management/`** — exemplo real e completo do pipeline rodado do início ao
  fim (PRD → TRD → código em `src/` → QA report → security review → SRE review), usado como
  referência de nível de detalhe esperado.
- **Cada feature nova** ganha uma pasta `NNNN-slug-em-kebab-case/` com os artefatos que forem
  sendo produzidos por cada etapa.

## `src/` — código de produção de backend, em ports & adapters

- **`domain/`** — entidades e regras de negócio puras, sem dependência de framework ou infra.
- **`application/ports/`** — interfaces que a aplicação exige da infraestrutura (definidas pelo
  que o caso de uso precisa).
- **`application/use_cases/`** — orquestram domínio + ports para cumprir um critério de aceite;
  dependem só de abstrações.
- **`adapters/inbound/`** — o que aciona os casos de uso (CLI, HTTP, eventos). Quando a feature
  tem frontend, implementa exatamente o contrato definido no TRD.
- **`adapters/outbound/`** — o que implementa os ports (persistência, serviços externos).

Detalhe completo em `docs/ARCHITECTURE.md`. Escrito pelo `backend-developer`.

## `frontend/` — código de produção de frontend (quando a feature tem UI)

- **`src/components/`** — UI; não fala com rede diretamente.
- **`src/services/`** — client da API, implementando o contrato do TRD; a camada que os
  componentes usam para falar com o backend (ou com um dublê, em desenvolvimento paralelo).
- **`tests/`** — testes de componente/serviço.

Detalhe completo em `docs/ARCHITECTURE.md` (seção "Frontend"). Escrito pelo `frontend-developer`.
Não existe neste repositório hoje — o exemplo (`specs/0001-example-task-management/`) é
backend-only.

## `tests/` — testes de backend, espelhando `src/`

- **`unit/`** — testa `domain` e `application` isoladamente, com dublês dos ports.
- **`integration/`** — testa implementações reais de adapters de saída contra o contrato do port.
- **`e2e/`** — testa o fluxo completo através de um adapter de entrada real.

Detalhe completo em `docs/TESTING.md`.

## `infra/` — containerização e infraestrutura como código

- **`docker/Dockerfile`** — build multi-stage da aplicação de exemplo, imagem final mínima,
  usuário não-root.
- **`docker/docker-compose.yml`** — como subir a aplicação (e dependências, se houver)
  localmente, do jeito mais próximo possível de produção.
- **`terraform/`** — infraestrutura como código: `main.tf` (recursos), `variables.tf` (entradas,
  com `sensitive = true` onde aplicável), `outputs.tf` (saídas), `modules/` (componentes
  reutilizáveis entre ambientes). É um esqueleto ilustrativo — adapte o provider/recursos ao
  ambiente real de destino antes de aplicar.

## `.github/workflows/` — pipelines de CI/CD

- **`ci.yml`** — roda em todo push/PR: lint, suíte de testes, gate de cobertura de 80%. Se
  qualquer um falhar, o PR não pode ser mergeado (configure a branch protection do GitHub para
  exigir este check).
- **`cd.yml`** — roda após CI verde em `main`: build/push da imagem Docker e
  `terraform plan`/`apply` gated por ambiente protegido (aprovação manual antes de `apply`).

## Arquivos de configuração da stack de exemplo

- **`pyproject.toml`** — configuração do exemplo Python: dependências de dev (`pytest`,
  `coverage`, `ruff`), e o gate de cobertura de 80% (`--cov-fail-under=80`).
- **`.gitignore`** — padrões a ignorar (ambientes virtuais, caches, artefatos de build,
  state do Terraform).
