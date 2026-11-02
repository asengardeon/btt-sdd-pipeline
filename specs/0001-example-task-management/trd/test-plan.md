<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Plano de testes

> Seção 11 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 11. Plano de testes (alto nível)

- Unitário (`tests/unit/`): `domain/task.py` (invariantes) e cada caso de uso com um
  `FakeTaskRepository` local ao teste.
- Integração (`tests/integration/`): `InMemoryTaskRepository` contra o contrato do port
  (`save`/`get`/`list_all`, incluindo upsert).
- E2E (`tests/e2e/`): fluxo completo via `TaskCLI.run` — criar → listar → concluir, mais os
  cenários de erro (título vazio, id inexistente, conclusão duplicada).
- Meta de cobertura: 80% (padrão do repositório).
