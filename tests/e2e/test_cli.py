import re

from adapters.inbound.cli import run
from adapters.outbound.in_memory_task_repository import InMemoryTaskRepository


def test_create_then_list_then_complete_flow():
    repository = InMemoryTaskRepository()

    create_output = run(["create", "Write PRD"], repository)
    assert "[pending]" in create_output
    assert "Write PRD" in create_output

    task_id = re.search(r"\[pending\] (\S+) —", create_output).group(1)

    list_output = run(["list"], repository)
    assert "Write PRD" in list_output

    complete_output = run(["complete", task_id], repository)
    assert "[done]" in complete_output

    list_output_after = run(["list"], repository)
    assert "[done]" in list_output_after


def test_list_with_no_tasks():
    repository = InMemoryTaskRepository()

    assert run(["list"], repository) == "no tasks"


def test_complete_unknown_task_reports_error_without_raising():
    repository = InMemoryTaskRepository()

    output = run(["complete", "unknown-id"], repository)

    assert "not found" in output
