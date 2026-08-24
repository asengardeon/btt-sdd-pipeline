from __future__ import annotations

import uuid
from dataclasses import dataclass

from application.ports.task_repository import TaskRepository
from domain.task import Task


@dataclass
class CreateTaskUseCase:
    repository: TaskRepository

    def execute(self, title: str) -> Task:
        task = Task(id=str(uuid.uuid4()), title=title)
        self.repository.save(task)
        return task
