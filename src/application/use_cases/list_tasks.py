from __future__ import annotations

from dataclasses import dataclass

from application.ports.task_repository import TaskRepository
from domain.task import Task


@dataclass
class ListTasksUseCase:
    repository: TaskRepository

    def execute(self) -> list[Task]:
        return self.repository.list_all()
