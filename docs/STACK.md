# Stack Tecnológica

Gerado/mantido pelo agente `architect` (processo em `.claude/agents/architect.md`). É a fonte que
qualquer TRD novo neste repositório reaproveita para não perguntar a stack de novo — ver seção
"Stack Tecnológica" de `specs/_template/trd.template.md`.

- **Linguagem/runtime**: Python 3.11+
- **Framework principal**: nenhum (só stdlib) — o exemplo (`specs/0001-example-task-management/`)
  é uma CLI simples via `argparse`; se uma feature futura precisar de um framework web (ex.:
  FastAPI, Flask), isso é decidido e registrado aqui na hora, não antes.
- **Persistência**: nenhuma em produção ainda — o exemplo usa um repositório em memória
  (`InMemoryTaskRepository`) deliberadamente, por escopo (ver PRD/TRD de `0001-...`). Uma feature
  que precisar de persistência real decide e registra o banco aqui.
- **Gerenciador de pacotes**: `pip` + `pyproject.toml` (padrão `setuptools`)
- **Testes/cobertura**: `pytest` + `pytest-cov`, gate de 80% (ver `docs/TESTING.md`)
- **Lint**: `ruff`

## Proveniência

Decidida durante o TRD da feature `0001-example-task-management` (`specs/0001-example-task-management/trd.md`),
retroativamente registrada aqui quando este arquivo foi criado — a decisão já existia
implicitamente no código, só não estava centralizada num único lugar até agora.

## Log de revisões

| Data       | Autor              | O que mudou                | Motivo                                                      |
|------------|----------------------|-------------------------------|------------------------------------------------------------------|
| 2026-08-24 | sessão Claude Code    | Criação deste arquivo          | Fechar a lacuna de "onde a stack é definida" — ver TRD do exemplo |
