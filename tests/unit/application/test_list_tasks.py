from application.use_cases.list_tasks import ListTasksUseCase
from domain.task import Task


class FakeTaskRepository:
    def __init__(self, tasks=None):
        self._tasks = tasks or []

    def save(self, task):
        self._tasks.append(task)

    def get(self, task_id):
        return next((t for t in self._tasks if t.id == task_id), None)

    def list_all(self):
        return list(self._tasks)


def test_list_tasks_returns_empty_when_no_tasks():
    use_case = ListTasksUseCase(FakeTaskRepository())

    assert use_case.execute() == []


def test_list_tasks_returns_all_stored_tasks():
    tasks = [Task(id="1", title="A"), Task(id="2", title="B")]
    use_case = ListTasksUseCase(FakeTaskRepository(tasks))

    result = use_case.execute()

    assert result == tasks
