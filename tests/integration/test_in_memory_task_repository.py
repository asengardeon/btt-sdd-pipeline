from adapters.outbound.in_memory_task_repository import InMemoryTaskRepository
from domain.task import Task


def test_save_then_get_returns_the_same_task():
    repository = InMemoryTaskRepository()
    task = Task(id="1", title="Write TRD")

    repository.save(task)

    assert repository.get("1") is task


def test_get_returns_none_for_unknown_id():
    repository = InMemoryTaskRepository()

    assert repository.get("unknown") is None


def test_save_overwrites_existing_task_with_same_id():
    repository = InMemoryTaskRepository()
    task = Task(id="1", title="Write TRD")
    repository.save(task)

    task.complete()
    repository.save(task)

    assert repository.get("1").done is True


def test_list_all_returns_every_saved_task():
    repository = InMemoryTaskRepository()
    repository.save(Task(id="1", title="A"))
    repository.save(Task(id="2", title="B"))

    result = repository.list_all()

    assert {task.id for task in result} == {"1", "2"}
