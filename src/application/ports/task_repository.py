from __future__ import annotations

from abc import ABC, abstractmethod

from domain.task import Task


class TaskRepository(ABC):
    """Port for persisting and retrieving tasks.

    Any adapter implementing this must be interchangeable with any other
    (Liskov substitution) without use cases noticing a behavior difference.
    """

    @abstractmethod
    def save(self, task: Task) -> None:
        """Create or update a task."""

    @abstractmethod
    def get(self, task_id: str) -> Task | None:
        """Return the task with the given id, or None if it doesn't exist."""

    @abstractmethod
    def list_all(self) -> list[Task]:
        """Return all tasks."""
