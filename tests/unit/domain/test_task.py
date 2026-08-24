import pytest

from domain.task import EmptyTaskTitleError, Task, TaskAlreadyCompletedError


def test_creates_task_as_pending_by_default():
    task = Task(id="1", title="Write PRD")

    assert task.title == "Write PRD"
    assert task.done is False


@pytest.mark.parametrize("title", ["", "   "])
def test_rejects_empty_or_blank_title(title):
    with pytest.raises(EmptyTaskTitleError):
        Task(id="1", title=title)


def test_complete_marks_task_as_done():
    task = Task(id="1", title="Write PRD")

    task.complete()

    assert task.done is True


def test_complete_twice_raises():
    task = Task(id="1", title="Write PRD")
    task.complete()

    with pytest.raises(TaskAlreadyCompletedError):
        task.complete()
