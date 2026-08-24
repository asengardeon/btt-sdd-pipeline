# TRD — Gestão simples de tarefas (exemplo do pipeline SDD)

> Status: aprovado
> Autor: agente `architect`
> PRD relacionado: `specs/0001-example-task-management/prd.md`
> ADRs relacionados: nenhum (design direto, sem trade-off significativo a registrar)

## 1. Contexto

Implementar criar/listar/concluir tarefas como exemplo de referência do pipeline, usando Python
como stack ilustrativa, respeitando ports & adapters, SOLID, TDD e o gate de cobertura de 80%.

## 2. Visão de arquitetura

```
[CLI (adapters/inbound/cli.py)] → [CreateTask / ListTasks / CompleteTask] → [TaskRepository port]
                                              ↓                                      ↑
                                     [domain/task.py]              [InMemoryTaskRepository
                                                                     (adapters/outbound)]
```

## 3. Modelo de domínio

`Task` (`src/domain/task.py`): `id: str`, `title: str`, `done: bool = False`.

Invariantes:
- Título não pode ser vazio/em branco — viola gera `EmptyTaskTitleError` na construção.
- Uma tarefa já concluída não pode ser concluída de novo — viola gera `TaskAlreadyCompletedError`.

## 4. Ports (contratos)

### `TaskRepository` (`src/application/ports/task_repository.py`)

- Responsabilidade única: persistir e recuperar tarefas.
- Métodos:
  - `save(task: Task) -> None` — cria ou atualiza (upsert por `id`).
  - `get(task_id: str) -> Task | None`
  - `list_all() -> list[Task]`
- Quem implementa: `InMemoryTaskRepository`.
- Quem consome: `CreateTaskUseCase`, `ListTasksUseCase`, `CompleteTaskUseCase`.

## 5. Casos de uso

| Critério de aceite (PRD)                         | Caso de uso           | Ports usados     |
|-----------------------------------------------------|-------------------------|--------------------|
| US-1 (criar com título válido / rejeitar vazio)      | `CreateTaskUseCase`      | `TaskRepository`   |
| US-2 (listar vazio / listar existentes)              | `ListTasksUseCase`       | `TaskRepository`   |
| US-3 (concluir / concluir 2x / concluir inexistente) | `CompleteTaskUseCase`    | `TaskRepository`   |

Validação de título vazio acontece no construtor de `Task` (domínio), não no caso de uso — é uma
invariante do domínio, não uma regra de aplicação.

## 6. Adapters

### Entrada

- `TaskCLI` (`src/adapters/inbound/cli.py`): comandos `create <título>`, `list`, `complete <id>`.
  Formata a saída como texto; não contém lógica de negócio, só parsing de argumento e chamada aos
  casos de uso.

### Saída

- `InMemoryTaskRepository` (`src/adapters/outbound/in_memory_task_repository.py`): dicionário em
  memória, chave por `id`. Suficiente para o exemplo; uma implementação real (ex.: Postgres)
  substituiria esta classe sem alterar caso de uso ou domínio.

## 7. Contrato Frontend↔Backend (API)

- **Aplicável?** Não — esta feature é só backend (CLI local). Não há frontend consumindo nenhuma
  API; a própria CLI é a interface com o usuário. Ver `docs/ARCHITECTURE.md`, seção "Frontend",
  para quando esta seção passa a ser preenchida numa feature full-stack.

## 8. Modelo de dados / contratos externos

N/A — sem persistência real nem API externa neste exemplo.

## 9. Pilares de engenharia de software

- **Performance**: não se aplica — dataset trivial, em memória, latência irrelevante para o
  propósito de exemplo/demonstração.
- **Escalabilidade**: não se aplica — a feature não introduz estado compartilhado entre
  instâncias; `InMemoryTaskRepository` é deliberadamente per-processo (fora de escopo:
  persistência real, ver PRD).
- **Resiliência**: não se aplica — nenhuma dependência externa (sem rede, sem chamada a serviço
  de terceiro), logo não há timeout/retry/circuit breaker a definir.
- **Disponibilidade**: irrelevante — é uma CLI de execução curta e local, não um serviço de longa
  duração; não há SLA/uptime a definir.
- **Observabilidade** (logs/métricas mínimas): a saída da própria CLI (`_format_task`) já serve
  como log mínimo suficiente para este exemplo; não há necessidade de logging estruturado ou
  métricas para uma CLI local de demonstração.
- **Manutenibilidade**: nenhum desvio de SOLID/Clean Code (`docs/ARCHITECTURE.md`) — a
  implementação segue ports & adapters estritamente, como o restante do repositório.
- **Impacto em infraestrutura para o SRE revisar:** nenhum além do Dockerfile/CI padrão do
  template — não há serviço de longa duração nem recurso de nuvem específico exigido por esta
  feature.
- **Indicadores técnicos herdados do PRD**: volumetria trivial, sem indicador de segurança e sem
  indicador legal (ver seção 8 do `prd.md`) — nenhum dos três exige decisão técnica adicional
  além do que já está desenhado (repositório em memória, sem rede, sem dado pessoal). O indicador
  de segurança é aprofundado em `specs/0001-example-task-management/security-review.md`.

## 10. Plano de testes (alto nível)

- Unitário (`tests/unit/`): `domain/task.py` (invariantes) e cada caso de uso com um
  `FakeTaskRepository` local ao teste.
- Integração (`tests/integration/`): `InMemoryTaskRepository` contra o contrato do port
  (`save`/`get`/`list_all`, incluindo upsert).
- E2E (`tests/e2e/`): fluxo completo via `TaskCLI.run` — criar → listar → concluir, mais os
  cenários de erro (título vazio, id inexistente, conclusão duplicada).
- Meta de cobertura: 80% (padrão do repositório).

## 11. Riscos e trade-offs

- Repositório em memória não persiste entre execuções da CLI — aceito, é o escopo explícito do
  PRD (fora de escopo: persistência real).

## 12. Decomposição de tarefas e dependências

| ID   | Tarefa                                    | Trilha  | Depende de | Issue GitHub      |
|------|----------------------------------------------|-----------|---------------|------------------------|
| T-1  | `CreateTaskUseCase` + `Task` (domínio)          | backend   | nenhuma        | não espelhada (sem remote GitHub configurado neste repositório) |
| T-2  | `ListTasksUseCase`                              | backend   | T-1 (precisa haver tarefa para listar de forma útil, embora tecnicamente independente) | não espelhada |
| T-3  | `CompleteTaskUseCase`                           | backend   | T-1             | não espelhada |
| T-4  | `TaskCLI` (adapter de entrada) + `InMemoryTaskRepository` (adapter de saída) | backend | T-1, T-2, T-3 | não espelhada |

Sem trilha de frontend (feature backend-only) — nenhuma dependência cross-trilha a coordenar.

## 13. Controle de versão (GitHub Flow)

- Branch: `feature/0001-example-task-management`
- PR: não aplicável — esta feature de exemplo foi commitada diretamente em `main` no commit
  inicial do repositório, antes da política de GitHub Flow existir (ver "Exceção histórica" em
  `docs/GIT-WORKFLOW.md`). Toda feature a partir de agora segue o fluxo de branch/PR normalmente.

## 14. Pendências de validação (VALIDAR DEPOIS)

Nenhuma.

## 15. Log de revisões

| Data       | Autor                 | O que mudou                                                              | Motivo                                                                 | Etapas revalidadas |
|------------|------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------------|------------------------|
| 2026-08-24 | sessão Claude Code      | Adicionadas as seções "Controle de versão", "Pendências de validação" e este log; adicionada referência a indicadores técnicos herdados do PRD na seção 8; renumeradas as seções seguintes | Alinhamento com o novo template (`specs/_template/trd.template.md`) após reforço de governança do pipeline | Nenhuma — mudança só de estrutura do documento, sem alterar arquitetura, ports ou casos de uso |
| 2026-08-24 | sessão Claude Code      | Seção 8 "Requisitos não funcionais" virou "Pilares de engenharia de software", com cada pilar (performance, escalabilidade, resiliência, disponibilidade, observabilidade, manutenibilidade) respondido explicitamente | Adição do agente `security-engineer` e dos pilares de engenharia (`docs/ENGINEERING-PILLARS.md`) ao pipeline | Nenhuma — respostas são "não se aplica" com justificativa, mesma conclusão técnica de antes, só explicitada |
| 2026-08-24 | sessão Claude Code      | Adicionadas as seções "Contrato Frontend↔Backend" (não aplicável) e "Decomposição de tarefas e dependências"; renumeradas as seções seguintes; referências a `senior-developer` trocadas por `backend-developer` | Split do agente de desenvolvimento em backend/frontend, contrato de API no TRD, e mapeamento de dependências entre tarefas | Nenhuma — mudança só de estrutura/nomenclatura, sem alterar arquitetura, ports ou casos de uso |

## 16. Aprovação

- [x] Aprovado por: asengardeons@hotmail.com em 2026-08-24
