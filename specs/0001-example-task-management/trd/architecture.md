<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Arquitetura

> Seções 3-5, 7, 9 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 3. Visão de arquitetura

```
[CLI (adapters/inbound/cli.py)] → [CreateTask / ListTasks / CompleteTask] → [TaskRepository port]
                                              ↓                                      ↑
                                     [domain/task.py]              [InMemoryTaskRepository
                                                                     (adapters/outbound)]
```

## 4. Modelo de domínio

`Task` (`src/domain/task.py`): `id: str`, `title: str`, `done: bool = False`.

Invariantes:
- Título não pode ser vazio/em branco — viola gera `EmptyTaskTitleError` na construção.
- Uma tarefa já concluída não pode ser concluída de novo — viola gera `TaskAlreadyCompletedError`.

## 5. Ports (contratos)

### `TaskRepository` (`src/application/ports/task_repository.py`)

- Responsabilidade única: persistir e recuperar tarefas.
- Métodos:
  - `save(task: Task) -> None` — cria ou atualiza (upsert por `id`).
  - `get(task_id: str) -> Task | None`
  - `list_all() -> list[Task]`
- Quem implementa: `InMemoryTaskRepository`.
- Quem consome: `CreateTaskUseCase`, `ListTasksUseCase`, `CompleteTaskUseCase`.

## 7. Adapters

### Entrada

- `TaskCLI` (`src/adapters/inbound/cli.py`): comandos `create <título>`, `list`, `complete <id>`.
  Formata a saída como texto; não contém lógica de negócio, só parsing de argumento e chamada aos
  casos de uso.

### Saída

- `InMemoryTaskRepository` (`src/adapters/outbound/in_memory_task_repository.py`): dicionário em
  memória, chave por `id`. Suficiente para o exemplo; uma implementação real (ex.: Postgres)
  substituiria esta classe sem alterar caso de uso ou domínio.

## 9. Modelo de dados / contratos externos

N/A — sem persistência real nem API externa neste exemplo.
