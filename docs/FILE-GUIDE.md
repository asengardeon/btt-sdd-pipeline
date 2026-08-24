# Guia de arquivos — o que cada arquivo/pasta faz

Referência item a item do repositório. Para o *porquê* das decisões, veja `docs/ARCHITECTURE.md`
e `docs/SDD-WORKFLOW.md`; este documento é sobre *o que cada coisa é*.

## Raiz

- **`CLAUDE.md`** — arquivo que o Claude Code carrega automaticamente no início de toda sessão
  neste repositório. É o ponto de entrada: resume o pipeline, os princípios e onde encontrar
  cada detalhe. Se você só vai ler um arquivo, é este.
- **`README.md`** — introdução para humanos (não é carregado automaticamente pelo Claude Code):
  o que é o repositório e como começar a usá-lo.

## `.claude/agents/` — os 5 agentes do pipeline

Cada arquivo `.md` aqui define um **subagente** invocável pela ferramenta Agent/Task do Claude
Code. O nome do arquivo (sem `.md`) é o `subagent_type`. O frontmatter YAML no topo declara nome,
descrição (usada para o Claude decidir quando invocar) e quais ferramentas o agente pode usar; o
corpo do arquivo é o "prompt de sistema" daquele agente — seu papel, regras e processo.

Todos os 5 têm `AskUserQuestion` — é o mecanismo pelo qual param e perguntam ao usuário de verdade
em vez de assumir (regra de governança em `docs/QUALITY-GATES.md`), sempre oferecendo "VALIDAR
DEPOIS" como opção quando cabível.

- **`product-design.md`** — gera o PRD a partir de um pedido. Não roda comandos (sem acesso a
  `Bash`) porque essa etapa é puramente de produto.
- **`architect.md`** — gera o TRD a partir do PRD aprovado. Também sem `Bash`.
- **`senior-developer.md`** — implementa a feature via TDD a partir do TRD, dentro de uma branch
  GitHub Flow. Tem acesso a `Bash` porque precisa rodar testes/lint/git durante o ciclo
  red-green-refactor. Apresenta um plano de implementação e pede aprovação antes do primeiro
  commit.
- **`qa-engineer.md`** — valida a implementação contra PRD/TRD e o PR aberto. Tem `Bash` para
  rodar a suíte de testes e o relatório de cobertura, mas não tem `Write`/`Edit` — QA não corrige
  código, reporta.
- **`sre.md`** — valida/ajusta CI/CD e infraestrutura. Tem `Bash`, `Write` e `Edit` porque pode
  precisar ajustar arquivos de `infra/` e `.github/workflows/` diretamente; qualquer alteração
  real de infraestrutura passa por um plano aprovado antes de executar.

## `.claude/skills/` — os comandos que acionam o pipeline

Cada subpasta é uma skill invocável como slash command (`/nome-da-pasta`). O arquivo
`SKILL.md` dentro dela contém as instruções que o Claude segue quando o comando é chamado —
tipicamente: validar pré-condição, invocar o agente correspondente, e comunicar o resultado.

- **`sdd-prd/`** → `/sdd-prd` — aciona `product-design`.
- **`sdd-trd/`** → `/sdd-trd` — aciona `architect`.
- **`sdd-implement/`** → `/sdd-implement` — aciona `senior-developer`.
- **`sdd-qa/`** → `/sdd-qa` — aciona `qa-engineer`.
- **`sdd-sre/`** → `/sdd-sre` — aciona `sre`.
- **`sdd-status/`** → `/sdd-status` — utilitário de leitura, não aciona nenhum agente; mostra em
  que etapa cada feature de `specs/` está, quantas pendências VALIDAR DEPOIS tem, e se alguma
  etapa foi marcada "requer revalidação" por uma emenda.
- **`sdd-amend/`** → `/sdd-amend` — utilitário de edição, não aciona nenhum agente; emenda um
  artefato já aprovado in-place e marca só as etapas posteriores realmente afetadas como "requer
  revalidação", sem reiniciar o pipeline da primeira etapa.
- **`sdd-pending/`** → `/sdd-pending` — utilitário de leitura, não aciona nenhum agente; lista
  todos os itens "VALIDAR DEPOIS" em aberto em todas as features.

## `docs/` — documentação de referência

- **`ARCHITECTURE.md`** — explica ports & adapters, SOLID e clean code, e como mapeiam para
  `src/`.
- **`SDD-WORKFLOW.md`** — explica o pipeline de 5 etapas em detalhe: entrada/saída/gate de cada
  uma.
- **`TESTING.md`** — explica TDD, a pirâmide de testes e o gate de cobertura de 80%.
- **`QUALITY-GATES.md`** — checklist único e não-negociável dos gates críticos do pipeline
  (governança de decisão, PRD, TRD, implementação, QA, SRE, merge) — referência central citada por
  todos os agentes, para não duplicar a lista em cinco lugares.
- **`GIT-WORKFLOW.md`** — GitHub Flow aplicado ao pipeline: convenção de branch, PR, proteção de
  `main`, e como cada etapa do SDD se relaciona com branch/PR/merge.
- **`FILE-GUIDE.md`** — este arquivo.
- **`adr/`** — Architecture Decision Records. Cada arquivo numerado registra uma decisão técnica
  significativa (contexto, opções consideradas, decisão, consequências). `0001-...md` é o próprio
  ADR que estabelece a convenção de registrar ADRs — leia-o como modelo antes de criar o próximo.

## `specs/` — os artefatos do pipeline SDD, um diretório por feature

- **`_template/`** — os modelos (`prd.template.md`, `trd.template.md`, `qa-report.template.md`,
  `sre-review.template.md`) que os agentes preenchem. Não é uma feature, é a fôrma usada por
  todas. Todos os quatro têm uma seção "Pendências de validação (VALIDAR DEPOIS)" e um "Log de
  revisões" (preenchido pelo `/sdd-amend`); o PRD também tem "Indicadores técnicos a observar"
  (volumetria, segurança, legal) e o TRD tem "Controle de versão (GitHub Flow)" (branch/PR).
- **`0001-example-task-management/`** — exemplo real e completo do pipeline rodado do início ao
  fim (PRD → TRD → código em `src/` → QA report → SRE review), usado como referência de nível de
  detalhe esperado.
- **Cada feature nova** ganha uma pasta `NNNN-slug-em-kebab-case/` com os artefatos que forem
  sendo produzidos por cada etapa.

## `src/` — código de produção, em ports & adapters

- **`domain/`** — entidades e regras de negócio puras, sem dependência de framework ou infra.
- **`application/ports/`** — interfaces que a aplicação exige da infraestrutura (definidas pelo
  que o caso de uso precisa).
- **`application/use_cases/`** — orquestram domínio + ports para cumprir um critério de aceite;
  dependem só de abstrações.
- **`adapters/inbound/`** — o que aciona os casos de uso (CLI, HTTP, eventos).
- **`adapters/outbound/`** — o que implementa os ports (persistência, serviços externos).

Detalhe completo em `docs/ARCHITECTURE.md`.

## `tests/` — testes, espelhando `src/`

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
