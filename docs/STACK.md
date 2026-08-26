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

## Simulação de nuvem local (dev/teste)

Quando uma feature introduz um **adapter de saída que fala com um serviço gerenciado de nuvem**
(ex.: AWS S3/DynamoDB/SQS/Lambda, Azure Blob Storage, GCP Cloud Storage, OCI Object Storage), o
padrão deste template é **não** usar a conta real de nuvem nem um mock artificial do SDK em
desenvolvimento local e em testes de integração — e sim [floci](https://floci.io) (MIT), que sobe
esses serviços localmente (em processo nativo via `floci start` ou em container Docker,
`floci/floci:latest`) com credenciais fictícias, sem custo e sem depender de rede externa.

- **Por quê**: mantém a pirâmide de testes (`docs/TESTING.md`) fiel — a camada de integração
  exercita o adapter real contra uma dependência real e containerizada, só que local, em vez de um
  dublê que pode divergir do comportamento de verdade do provedor (paginação, erros específicos do
  serviço, formato de resposta).
- **Quando decidir**: o `architect` decide isso ao desenhar cada adapter de saída que depende de um
  serviço de nuvem gerenciado (`.claude/agents/architect.md`, etapa de definição de adapters) —
  nunca fica implícito. Fica registrado aqui (tabela abaixo) e no TRD da feature que introduziu a
  dependência.
- **Escopo**: floci é **só para desenvolvimento local e testes** (unitário usa dublê do port, como
  sempre; integração usa floci; CI roda floci como serviço efêmero do pipeline). Em produção, o
  adapter real fala com o provedor de nuvem de verdade — a troca entre os dois é só a
  implementação do port injetada (Liskov, `docs/ARCHITECTURE.md`), nunca um `if` de ambiente dentro
  do caso de uso.
- **Portas padrão** (quando rodando via container `floci/floci:latest`): AWS `4566`, Azure `4577`,
  GCP `4588`, OCI `4599`.

| Serviço de nuvem usado | Provedor emulado por floci | Registrado em                     |
|-------------------------|-----------------------------|-------------------------------------|
| _(nenhum ainda — preenchido pelo `architect` na primeira feature que precisar)_ | — | — |

## Proveniência

Decidida durante o TRD da feature `0001-example-task-management` (`specs/0001-example-task-management/trd.md`),
retroativamente registrada aqui quando este arquivo foi criado — a decisão já existia
implicitamente no código, só não estava centralizada num único lugar até agora.

## Log de revisões

| Data       | Autor              | O que mudou                | Motivo                                                      |
|------------|----------------------|-------------------------------|------------------------------------------------------------------|
| 2026-08-25 | sessão Claude Code    | Adiciona seção "Simulação de nuvem local (dev/teste)" (floci) | Padronizar o uso de floci.io para simular AWS/Azure/GCP/OCI localmente em vez de contas reais ou mocks de SDK |
| 2026-08-24 | sessão Claude Code    | Criação deste arquivo          | Fechar a lacuna de "onde a stack é definida" — ver TRD do exemplo |
