<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Decomposição de tarefas

> Seção 13 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 13. Decomposição de tarefas e dependências

Tabela na forma original desta spec (anterior à introdução das colunas "Fatia (PRD)", "Validação
na fatia" e "Status" no template, e à introdução da subseção "Janelas de quebra de contrato entre
fatias") — não inventadas nesta migração. Esta feature foi entregue como uma única fatia; não há
coluna de Status porque a tarefa concluída/mergeada é a própria feature (commitada diretamente em
`main` no commit inicial do repositório, antes da política de GitHub Flow existir).

| ID   | Tarefa                                    | Trilha  | Depende de | Issue GitHub      |
|------|----------------------------------------------|-----------|---------------|------------------------|
| T-1  | `CreateTaskUseCase` + `Task` (domínio)          | backend   | nenhuma        | não espelhada (sem remote GitHub configurado neste repositório) |
| T-2  | `ListTasksUseCase`                              | backend   | T-1 (precisa haver tarefa para listar de forma útil, embora tecnicamente independente) | não espelhada |
| T-3  | `CompleteTaskUseCase`                           | backend   | T-1             | não espelhada |
| T-4  | `TaskCLI` (adapter de entrada) + `InMemoryTaskRepository` (adapter de saída) | backend | T-1, T-2, T-3 | não espelhada |

Sem trilha de frontend (feature backend-only) — nenhuma dependência cross-trilha a coordenar.

### Janelas de quebra de contrato entre fatias

Não aplicável — feature entregue como uma única fatia, sem fatia posterior dependente.
