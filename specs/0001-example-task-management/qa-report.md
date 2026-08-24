# QA Report — Gestão simples de tarefas (exemplo do pipeline SDD)

> Autor: agente `qa-engineer`
> PRD: `specs/0001-example-task-management/prd.md` | TRD: `specs/0001-example-task-management/trd.md`
> Data: 2026-08-24

## 1. Veredito geral

**Aprovado**

## 2. Cobertura de testes

| Métrica            | Resultado | Gate  | Status |
|---------------------|-----------|-------|--------|
| Cobertura de linhas  | 98.44%    | 80%   | ✅     |
| Cobertura de branches| incluída no total acima (`--cov-branch`) | 80% | ✅ |

Comando usado: `pytest --cov=src --cov-report=term-missing` (config de gate `fail_under = 80` em
`pyproject.toml`).

## 3. Critérios de aceite (PRD)

| ID    | Critério                                             | Teste automatizado                                                        | Veredito |
|-------|---------------------------------------------------------|-------------------------------------------------------------------------------|----------|
| US-1  | Criar tarefa com título válido                            | `tests/unit/application/test_create_task.py::test_create_task_persists_and_returns_task` | ✅ |
| US-1  | Rejeitar criação com título vazio                          | `tests/unit/domain/test_task.py::test_rejects_empty_or_blank_title` e `tests/unit/application/test_create_task.py::test_create_task_with_empty_title_raises_and_does_not_persist` | ✅ |
| US-2  | Listar quando não há tarefas                               | `tests/unit/application/test_list_tasks.py::test_list_tasks_returns_empty_when_no_tasks` e `tests/e2e/test_cli.py::test_list_with_no_tasks` | ✅ |
| US-2  | Listar tarefas existentes com status                       | `tests/unit/application/test_list_tasks.py::test_list_tasks_returns_all_stored_tasks` e `tests/e2e/test_cli.py::test_create_then_list_then_complete_flow` | ✅ |
| US-3  | Concluir tarefa existente                                   | `tests/unit/application/test_complete_task.py::test_complete_task_marks_it_done_and_persists` | ✅ |
| US-3  | Rejeitar conclusão de tarefa já concluída                   | `tests/unit/domain/test_task.py::test_complete_twice_raises`               | ✅ |
| US-3  | Erro claro ao concluir tarefa inexistente                   | `tests/unit/application/test_complete_task.py::test_complete_task_raises_when_not_found` e `tests/e2e/test_cli.py::test_complete_unknown_task_reports_error_without_raising` | ✅ |

## 4. Regressão

Suíte completa: 18 testes, 18 passaram, 0 falhas (`pytest`, ver seção 2 para comando exato com
cobertura).

## 5. Aderência a ports & adapters

Sim. Testes unitários (`tests/unit/`) usam um `FakeTaskRepository` definido no próprio arquivo de
teste, sem tocar `InMemoryTaskRepository` real nem I/O. Testes de integração
(`tests/integration/`) exercitam a implementação real do port isoladamente. Testes e2e
(`tests/e2e/`) passam pelo adapter de entrada (`TaskCLI.run`) até o adapter de saída real, sem
mock — condizente com o papel de cada camada da pirâmide.

## 6. Achados

Nenhum. Lint (`ruff check src tests`) sem apontamentos.

## 7. Próximo passo

`/sdd-sre`.
