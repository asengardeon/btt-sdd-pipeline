import pytest

from application.use_cases.complete_task import CompleteTaskUseCase, TaskNotFoundError
from domain.task import Task


class FakeTaskRepository:
    def __init__(self, tasks=None):
        self._tasks = {t.id: t for t in (tasks or [])}

    def save(self, task):
        self._tasks[task.id] = task

    def get(self, task_id):
        return self._tasks.get(task_id)

    def list_all(self):
        return list(self._tasks.values())


def test_complete_task_marks_it_done_and_persists():
    task = Task(id="1", title="Write TRD")
    repository = FakeTaskRepository([task])
    use_case = CompleteTaskUseCase(repository)

    result = use_case.execute("1")

    assert result.done is True
    assert repository.get("1").done is True


def test_complete_task_raises_when_not_found():
    repository = FakeTaskRepository()
    use_case = CompleteTaskUseCase(repository)

    with pytest.raises(TaskNotFoundError):
        use_case.execute("missing-id")
