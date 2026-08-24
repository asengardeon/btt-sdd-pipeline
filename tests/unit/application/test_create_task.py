import pytest

from application.use_cases.create_task import CreateTaskUseCase
from domain.task import EmptyTaskTitleError


class FakeTaskRepository:
    def __init__(self):
        self.saved = []

    def save(self, task):
        self.saved.append(task)

    def get(self, task_id):
        return next((t for t in self.saved if t.id == task_id), None)

    def list_all(self):
        return list(self.saved)


def test_create_task_persists_and_returns_task():
    repository = FakeTaskRepository()
    use_case = CreateTaskUseCase(repository)

    task = use_case.execute("Write TRD")

    assert task.title == "Write TRD"
    assert task.done is False
    assert repository.get(task.id) is task


def test_create_task_with_empty_title_raises_and_does_not_persist():
    repository = FakeTaskRepository()
    use_case = CreateTaskUseCase(repository)

    with pytest.raises(EmptyTaskTitleError):
        use_case.execute("")

    assert repository.list_all() == []
