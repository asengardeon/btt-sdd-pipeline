from __future__ import annotations

from dataclasses import dataclass

from application.ports.task_repository import TaskRepository
from domain.task import Task


class TaskNotFoundError(Exception):
    pass


@dataclass
class CompleteTaskUseCase:
    repository: TaskRepository

    def execute(self, task_id: str) -> Task:
        task = self.repository.get(task_id)
        if task is None:
            raise TaskNotFoundError(f"task {task_id} not found")
        task.complete()
        self.repository.save(task)
        return task
