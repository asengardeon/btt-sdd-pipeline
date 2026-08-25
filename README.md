# btt-sdd-pipeline

Template de desenvolvimento orientado a especificação (**SDD — Spec-Driven Development**) para o
Claude Code: cada feature nasce de um PRD, passa por um TRD, é implementada com TDD em ports &
adapters, é validada por QA e liberada por SRE — com um agente dedicado a cada etapa.

Comece por `CLAUDE.md` — é o arquivo que o Claude Code lê automaticamente e que explica todo o
pipeline. Para a explicação de cada arquivo/pasta deste repositório, veja `docs/FILE-GUIDE.md`.

## Pipeline

```
/sdd-prd  →  /sdd-trd  →  /sdd-implement  →  /sdd-qa  →  /sdd-sre
```

Use `/sdd-status` a qualquer momento para ver em que etapa cada feature está. Veja
`docs/SDD-WORKFLOW.md` para o detalhe de cada etapa e `specs/0001-example-task-management/` para
um exemplo completo já rodado (PRD, TRD, QA report, SRE review e o código correspondente em
`src/`/`tests/`).

## Instalação do plugin

O pipeline também existe empacotado como plugin instalável do Claude Code
(`plugins/btt-sdd/`), com namespace `/btt-sdd:`. Para instalar a partir do GitHub (repositório
privado — exige autenticação já configurada: `gh auth login` ou credenciais git):

```
claude plugin marketplace add asengardeon/btt-sdd-pipeline
claude plugin install btt-sdd@btt-sdd-pipeline
```

Veja `plugins/btt-sdd/README.md` para a instalação local (recomendada se você for editar o
próprio pipeline) e mais detalhes sobre os dois métodos.

## Rodando o exemplo (Python)

```bash
python -m venv .venv
source .venv/Scripts/activate   # Windows Git Bash; use .venv/bin/activate em Linux/Mac
pip install -e ".[dev]"

ruff check src tests
pytest --cov=src --cov-report=term-missing   # gate de 80% definido em pyproject.toml

python -m adapters.inbound.cli create "Minha primeira tarefa"
```

O exemplo (`specs/0001-example-task-management/`) é só ilustrativo do fluxo SDD — a stack real do
seu projeto pode ser outra; veja a nota sobre isso em `CLAUDE.md`.

## Docker / Terraform

```bash
docker build -f infra/docker/Dockerfile -t projeto-base-ia-example .
docker compose -f infra/docker/docker-compose.yml up
```

`infra/terraform/` é um esqueleto ilustrativo de infraestrutura (ECR + ECS Fargate na AWS como
exemplo) — leia `infra/terraform/README.md` antes de rodar `terraform apply` de verdade.
