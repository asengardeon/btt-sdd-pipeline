from __future__ import annotations

from dataclasses import dataclass


class EmptyTaskTitleError(ValueError):
    pass


class TaskAlreadyCompletedError(Exception):
    pass


@dataclass
class Task:
    id: str
    title: str
    done: bool = False

    def __post_init__(self) -> None:
        if not self.title or not self.title.strip():
            raise EmptyTaskTitleError("task title must not be empty")

    def complete(self) -> None:
        if self.done:
            raise TaskAlreadyCompletedError(f"task {self.id} is already completed")
        self.done = True
