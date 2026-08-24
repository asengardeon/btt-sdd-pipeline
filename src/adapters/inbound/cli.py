from __future__ import annotations

import argparse
from collections.abc import Sequence

from application.ports.task_repository import TaskRepository
from application.use_cases.complete_task import CompleteTaskUseCase, TaskNotFoundError
from application.use_cases.create_task import CreateTaskUseCase
from application.use_cases.list_tasks import ListTasksUseCase
from domain.task import Task


def _format_task(task: Task) -> str:
    status = "done" if task.done else "pending"
    return f"[{status}] {task.id} — {task.title}"


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="task-cli")
    subparsers = parser.add_subparsers(dest="command", required=True)

    create_parser = subparsers.add_parser("create")
    create_parser.add_argument("title")

    subparsers.add_parser("list")

    complete_parser = subparsers.add_parser("complete")
    complete_parser.add_argument("task_id")

    return parser


def run(argv: Sequence[str], repository: TaskRepository) -> str:
    args = build_arg_parser().parse_args(argv)

    if args.command == "create":
        task = CreateTaskUseCase(repository).execute(args.title)
        return _format_task(task)

    if args.command == "list":
        tasks = ListTasksUseCase(repository).execute()
        if not tasks:
            return "no tasks"
        return "\n".join(_format_task(task) for task in tasks)

    if args.command == "complete":
        try:
            task = CompleteTaskUseCase(repository).execute(args.task_id)
        except TaskNotFoundError as error:
            return str(error)
        return _format_task(task)

    raise AssertionError(f"unhandled command: {args.command}")


if __name__ == "__main__":
    import sys

    from adapters.outbound.in_memory_task_repository import InMemoryTaskRepository

    print(run(sys.argv[1:], InMemoryTaskRepository()))
