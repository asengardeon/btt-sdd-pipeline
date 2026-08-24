from __future__ import annotations

from application.ports.task_repository import TaskRepository
from domain.task import Task


class InMemoryTaskRepository(TaskRepository):
    """Test/demo implementation of TaskRepository backed by a dict."""

    def __init__(self) -> None:
        self._tasks: dict[str, Task] = {}

    def save(self, task: Task) -> None:
        self._tasks[task.id] = task

    def get(self, task_id: str) -> Task | None:
        return self._tasks.get(task_id)

    def list_all(self) -> list[Task]:
        return list(self._tasks.values())
