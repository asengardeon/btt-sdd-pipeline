<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Casos de uso

> Seção 6 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 6. Casos de uso

| Critério de aceite (PRD)                         | Caso de uso           | Ports usados     |
|-----------------------------------------------------|-------------------------|--------------------|
| US-1 (criar com título válido / rejeitar vazio)      | `CreateTaskUseCase`      | `TaskRepository`   |
| US-2 (listar vazio / listar existentes)              | `ListTasksUseCase`       | `TaskRepository`   |
| US-3 (concluir / concluir 2x / concluir inexistente) | `CompleteTaskUseCase`    | `TaskRepository`   |

Validação de título vazio acontece no construtor de `Task` (domínio), não no caso de uso — é uma
invariante do domínio, não uma regra de aplicação.
