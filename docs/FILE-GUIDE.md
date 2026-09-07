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
  (`claude plugin marketplace add` + `claude plugin install btt-sdd@btt-sdd-pipeline`).

## `plugins/btt-sdd/` — o pipeline empacotado como plugin instalável

Mesmo pipeline de `.claude/agents/`/`.claude/skills/` (ver seções abaixo), empacotado no formato
de plugin do Claude Code (`.claude-plugin/plugin.json` + `agents/` + `skills/`, incluindo
`create-project/scaffold/`). É uma **cópia própria**, não um link para `.claude/` — necessária
porque comandos instalados via plugin ganham o namespace `btt-sdd:` (`/btt-sdd:trd`, não
`/sdd-trd`), então toda referência interna a um comando `/sdd-*` dentro dos arquivos do plugin já
vem com esse prefixo. `plugins/btt-sdd/README.md` documenta o processo de replicar uma edição de
`.claude/agents/*.md`/`.claude/skills/*` para cá quando necessário. Instalação local testada e
confirmada funcionando (ver `CLAUDE.md`, seção "Distribuição global").

## `.claude/agents/` — os agentes do pipeline (7 + 1 condicional)

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
  decomposição de tarefas com dependências — toda tarefa precisa de uma Issue real do GitHub
  associada antes do TRD ser aprovado, obrigatório sempre que há remote conectado e autenticado; se
  não há, o TRD não pode ser finalizado (só o PRD dispensa GitHub). Tem `Bash` para checar
  `docs/STACK.md`/remote GitHub/`gh auth status` e criar essas issues.
- **`backend-developer.md`** — implementa a trilha de backend via TDD a partir do TRD, em `src/`,
  dentro de uma branch GitHub Flow. Tem acesso a `Bash` porque precisa rodar testes/lint/git
  durante o ciclo red-green-refactor. Apresenta um plano de implementação e pede aprovação antes
  do primeiro commit (a menos que orquestrado por `/sdd-implement` com plano já aprovado).
- **`frontend-developer.md`** — implementa a trilha de frontend via TDD a partir do TRD, em
  `frontend/`, contra o contrato definido pelo `architect`. Mesmo padrão de `Bash` e aprovação de
  plano de `backend-developer`. Quando a feature é full-stack, os dois rodam em paralelo,
  orquestrados por `/sdd-implement`.
- **`code-reviewer.md`** — engenheiro de software sênior fazendo *code review* do PR entre a
  implementação e o QA: ports & adapters, SOLID, clean code, qualidade dos próprios testes,
  contrato Frontend↔Backend quando full-stack. Tem `Bash` para ler o diff do PR, rodar lint, e
  commitar/enviar (push) o próprio `code-review.md` na branch do PR antes de terminar; `Write`/
  `Edit` só para esse arquivo — não corrige código de produção, reporta.
- **`qa-engineer.md`** — valida a implementação contra PRD/TRD e o PR aberto, depois da revisão
  de código aprovada. Tem `Bash` para rodar a suíte de testes e o relatório de cobertura quando
  precisa (o resumo já gerado pela implementação em `specs/<slug>/coverage/` é reaproveitado
  quando ainda corresponde ao commit atual — `docs/TESTING.md`), e para commitar/enviar (push) o
  próprio `qa-report.md` na branch do PR antes de terminar; `Write`/`Edit` só para esse arquivo —
  QA não corrige código de produção, reporta.
- **`security-engineer.md`** — revisa segurança da aplicação (OWASP, segredos, autenticação/
  autorização, validação de entrada, dependências) depois do QA. Mesma lógica de `Write`/`Edit`
  restrito ao próprio `security-review.md`, que também commita e envia (push) antes de terminar —
  não corrige código, reporta.
- **`sre.md`** — valida/ajusta CI/CD e infraestrutura, depois de QA e segurança aprovados. Tem
  `Bash`, `Write` e `Edit` porque pode precisar ajustar arquivos de `infra/` e
  `.github/workflows/` diretamente (commitando/enviando esses ajustes junto com `sre-review.md`
  antes de terminar); qualquer alteração real de infraestrutura passa por um plano aprovado antes
  de executar.
- **`tech-writer.md`** — agente **utilitário** de documentação técnica (README, `docs/*.md`, ADRs,
  exemplos de código documentados), sem posição fixa nas 7 etapas — convocável a qualquer momento,
  no mesmo espírito do `codebase-archaeologist`. Nunca escreve/corrige código de produção, só
  documenta o que existe de fato.

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
- **`sdd-code-review/`** → `/sdd-code-review` — aciona `code-reviewer`.
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
- **`sdd-gap-report/`** → `/sdd-gap-report <slug> [caminho-busca ...]` — utilitário de leitura,
  não aciona nenhum agente; compara os casos de uso da seção 6 do TRD com o código real em `src/`
  (e `frontend/`, quando existir), reportando implementado sim/não por caso de uso.
- **`sdd-docs/`** → `/sdd-docs` — aciona `tech-writer` (utilitário, sem posição fixa numa etapa);
  escreve/atualiza README, um doc de `docs/`, um ADR, ou transforma código real em exemplo
  documentado.
- **`sdd-hotfix/`** → `/sdd-hotfix` — utilitário fora das 7 etapas fixas; formaliza uma correção
  pontual pós-merge (bug em produção, ou melhoria pontual sem spec de origem), sem PRD/TRD mas com
  TDD e as revisões aplicáveis (code review sempre; QA/segurança/SRE por critério objetivo —
  `docs/SDD-WORKFLOW.md`, seção "Correção pontual pós-merge").
- **`repo-issues/`** → `/repo-issues` — utilitário **exclusivo deste repositório**, nunca
  replicado em `plugins/btt-sdd/` (`plugins/btt-sdd/README.md`, seção "⚠️ Isto é uma cópia, não um
  link"): lê as issues abertas em `asengardeon/btt-sdd-pipeline`, aplica as que fizerem sentido
  como mudança no pipeline, e abre um PR (com `Closes #N`) por issue aplicada, ajustando a versão
  do plugin quando a mudança tocar conteúdo empacotado.
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
- **`SDD-WORKFLOW.md`** — explica o pipeline de 7 etapas (+ 1 condicional) em detalhe:
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
  qualquer feature nova aqui não precisar perguntar de novo. Também registra, na seção "Simulação
  de nuvem local", quais adapters de saída falam com serviços de nuvem gerenciados (AWS/Azure/GCP/
  OCI) e que [floci](https://floci.io) é o padrão para emulá-los em dev/teste (ver
  `docs/TESTING.md`).
- **`LESSONS-LEARNED.md`** — **gerado condicionalmente** pelos agentes de revisão (`code-reviewer`,
  `qa-engineer`, `security-engineer`, `sre`): não existe por padrão, sua ausência já significa
  "nenhum padrão recorrente confirmado ainda". Nasce na primeira vez que um achado se repete
  (2ª ocorrência confirmada) numa revisão de feature diferente da que o levantou pela primeira
  vez — critério completo em `docs/QUALITY-GATES.md`, seção "Lições aprendidas recorrentes". Cada
  entrada vira uma restrição que `backend-developer`/`frontend-developer` aplicam na próxima
  implementação, sem esperar a revisão apontar de novo.
- **`POST-MERGE-VALIDATION.md`** — checklist leve para validação manual contra produção real
  depois de um merge (sessão autenticada real, confirmação de deploy efetivo, DNS/certificados,
  limpeza de dados de teste, e o lembrete de fechar itens "VALIDAR DEPOIS" via `/sdd-amend`).
  Referenciado por `.claude/skills/sdd-implement/SKILL.md`.
- **`FILE-GUIDE.md`** — este arquivo.
- **`adr/`** — Architecture Decision Records. Cada arquivo numerado registra uma decisão técnica
  significativa (contexto, opções consideradas, decisão, consequências). `0001-...md` é o próprio
  ADR que estabelece a convenção de registrar ADRs — leia-o como modelo antes de criar o próximo.

## `specs/` — os artefatos do pipeline SDD, um diretório por feature

- **`_template/`** — os modelos (`prd.template.md`, `trd.template.md`,
  `code-review.template.md`, `qa-report.template.md`, `security-review.template.md`,
  `sre-review.template.md`, `coverage-summary.template.md`) que os agentes preenchem. Não é uma
  feature, é a fôrma usada por todas. Todos os artefatos de revisão têm uma seção "Pendências de
  validação (VALIDAR DEPOIS)" e um "Log de revisões" (preenchido pelo `/sdd-amend`); o PRD também
  tem "Indicadores técnicos a observar" (volumetria, segurança, legal) e "Ordem de valor /
  dependências entre histórias"; o TRD tem "Pilares de engenharia de software", "Contrato
  Frontend↔Backend (API)", "Decomposição de tarefas e dependências" e "Controle de versão (GitHub
  Flow)" (branch/PR). `coverage-summary.template.md` é diferente dos demais — não é um artefato de
  revisão com veredito, é a evidência condensada (resultado de suíte + cobertura, nunca o relatório
  bruto) que `backend-developer`/`frontend-developer` geram e outras etapas reaproveitam em vez de
  re-executar a suíte (`docs/TESTING.md`).
- **`0001-example-task-management/`** — exemplo real e completo do pipeline rodado do início ao
  fim (PRD → TRD → QA report → security review → SRE review), usado como referência de nível de
  detalhe esperado. O código correspondente não existe mais como arquivos executáveis neste
  repositório — está documentado em `0001-example-task-management/code-examples.md`.
- **Cada feature nova** ganha uma pasta `NNNN-slug-em-kebab-case/` com os artefatos que forem
  sendo produzidos por cada etapa, incluindo uma subpasta `coverage/` com os resumos de cobertura
  por fatia/trilha e, quando a feature tem UI e o usuário aceitou ver opções (`/sdd-prd`, passo
  2b), uma subpasta `wireframes/` com o(s) arquivo(s)-fonte `.dc.html` das opções geradas —
  salvos junto da spec para conferência futura mesmo que o Artifact publicado não esteja mais
  acessível.

## `src/`, `tests/`, `frontend/`, `infra/`, `.github/workflows/` — não existem neste repositório hoje

Este é um template de **pipeline**, não de aplicação — depois que o app de exemplo
(`specs/0001-example-task-management/`) cumpriu seu papel de ilustrar o fluxo ponta a ponta, o
código executável foi removido (ver ADR `docs/adr/0002-remover-app-exemplo-manter-exemplos-documentados.md`)
e o valor ilustrativo ficou preservado como exemplo documentado em
`specs/0001-example-task-management/code-examples.md`. As convenções abaixo continuam sendo o que
`backend-developer`/`frontend-developer`/`sre` criam do zero na stack decidida no TRD, seja neste
repositório (se alguém implementar uma feature real aqui) ou em qualquer projeto que adote o
template — nada aqui deixou de valer, só deixou de estar fisicamente presente sem uma feature real
por trás.

- **`src/domain/`** — entidades e regras de negócio puras, sem dependência de framework ou infra.
- **`src/application/ports/`** — interfaces que a aplicação exige da infraestrutura (definidas
  pelo que o caso de uso precisa).
- **`src/application/use_cases/`** — orquestram domínio + ports para cumprir um critério de
  aceite; dependem só de abstrações.
- **`src/adapters/inbound/`** — o que aciona os casos de uso (CLI, HTTP, eventos). Quando a
  feature tem frontend, implementa exatamente o contrato definido no TRD.
- **`src/adapters/outbound/`** — o que implementa os ports (persistência, serviços externos).
- **`frontend/src/components/`** — UI; não fala com rede diretamente. **`frontend/src/services/`**
  — client da API, implementando o contrato do TRD. **`frontend/tests/`** — testes de
  componente/serviço.
- **`tests/unit/`** — testa `domain` e `application` isoladamente, com dublês dos ports.
  **`tests/integration/`** — testa implementações reais de adapters de saída contra o contrato do
  port. **`tests/e2e/`** — testa o fluxo completo através de um adapter de entrada real.
- **`infra/docker/Dockerfile`**/**`docker-compose.yml`** — build multi-stage e como subir a
  aplicação localmente. **`infra/terraform/`** — infraestrutura como código (`main.tf`,
  `variables.tf` com `sensitive = true` onde aplicável, `outputs.tf`, `modules/`).
- **`.github/workflows/ci.yml`**/**`cd.yml`** — lint + testes + gate de cobertura de 80% em todo
  PR; deploy gated por CI verde e aprovação manual de `terraform apply`.

Detalhe completo de cada convenção em `docs/ARCHITECTURE.md` (backend/frontend) e `docs/TESTING.md`
(testes/cobertura). Veja como cada peça ficava de fato em
`specs/0001-example-task-management/code-examples.md`.

## `scripts/` dentro de cada skill — utilitários para reduzir uso de tokens no pipeline

Scripts sh/PowerShell que fazem no shell o que, de outra forma, o agente faria lendo cada
artefato inteiro no contexto — vivem dentro da própria pasta da skill que os usa
(`.claude/skills/sdd-status/scripts/`, `.claude/skills/sdd-pending/scripts/`, e as cópias
equivalentes em `plugins/btt-sdd/skills/`), não num `scripts/` solto na raiz. Isso é proposital:
skills são o que viaja pela junction global (`~/.claude/skills`) e pelo empacotamento do plugin,
então um script guardado dentro da própria skill chega a qualquer projeto (mesmo um que nunca
passou por `/create-project`) sem precisar de cópia manual. O `SKILL.md` de cada uma referencia
o script via `${CLAUDE_SKILL_DIR}/scripts/...` — variável que o Claude Code resolve para a pasta
real da skill, seja ela alcançada pela junction, por um plugin instalado, ou localmente neste
repositório. `/sdd-status`, `/sdd-pending` e `/sdd-gap-report` preferem rodar o script e só caem
de volta para leitura manual dos artefatos se ele falhar. Best-effort via grep/awk/regex sobre a
convenção de formatação dos templates em `specs/_template/` — não são um parser de markdown
completo.

- **`sdd-status.sh` / `sdd-status.ps1`** (em `.claude/skills/sdd-status/scripts/`) — varre
  `specs/*/`, extrai etapa atual, próximo comando, contagem de pendências VALIDAR DEPOIS e
  sinalização de "requer revalidação" por feature.
- **`sdd-pending.sh` / `sdd-pending.ps1`** (em `.claude/skills/sdd-pending/scripts/`) — varre
  `specs/*/` e `docs/BASELINE.md`, lista só os itens VALIDAR DEPOIS com status "pendente".
- **`sdd-gap-report.sh` / `sdd-gap-report.ps1`** (em `.claude/skills/sdd-gap-report/scripts/`) —
  extrai a tabela da seção 6 (Casos de uso) de `specs/<slug>/trd.md` e faz grep de cada caso de
  uso em `src/`/`frontend/` (ou num caminho informado como argumento, para stacks com outra
  convenção de pastas), reportando implementado sim/não por caso de uso com o arquivo de
  evidência.

Como qualquer outro arquivo de skill, mudar o script exige replicar a mudança na cópia
equivalente em `plugins/btt-sdd/skills/` (ver "⚠️ Isto é uma cópia, não um link" em
`plugins/btt-sdd/README.md`).

## `.gitignore`

Padrões a ignorar (ambientes virtuais, caches, artefatos de build, state do Terraform) — mantido
mesmo sem o código de exemplo, já que qualquer feature real implementada neste repositório voltará
a gerar esses artefatos. `pyproject.toml` (manifesto de dependências do exemplo Python removido)
está documentado em `specs/0001-example-task-management/code-examples.md`.
