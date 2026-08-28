# Exemplos de código — Task Management (Python)

> Este arquivo documenta, como referência de leitura, o código que existiu de verdade em `src/`,
> `tests/`, `pyproject.toml`, `infra/` e `.github/workflows/` para esta feature — removido do
> repositório porque este é um template de **pipeline**, não de aplicação (ver
> `docs/adr/0002-remover-app-exemplo-manter-exemplos-documentados.md`). O PRD, TRD, QA report,
> security review e SRE review desta feature continuam reais e íntegros nos demais arquivos deste
> diretório; só o código executável foi removido. Os trechos abaixo rodavam de verdade e passavam
> nos testes — não são pseudocódigo.

## Domínio (`src/domain/task.py`)

Entidade pura, sem import de framework ou infraestrutura — a regra de negócio (título não pode ser
vazio, uma tarefa não pode ser concluída duas vezes) vive só aqui.

```python
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
```

## Port (`src/application/ports/task_repository.py`)

Interface definida pelo que o caso de uso precisa, não pelo que uma tecnologia de persistência
específica oferece — qualquer implementação deve ser substituível por outra sem o caso de uso
perceber diferença (Liskov).

```python
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
```

## Caso de uso (`src/application/use_cases/create_task.py`)

Orquestra domínio + port; recebe a implementação de `TaskRepository` por injeção, nunca instancia
um adapter concreto internamente.

```python
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
```

(`list_tasks.py` e `complete_task.py` seguem o mesmo formato — um caso de uso por critério de
aceite, cada um com uma única responsabilidade.)

## Adapter outbound (`src/adapters/outbound/in_memory_task_repository.py`)

Implementação de demonstração do port, usada tanto pela CLI quanto pelos testes de integração —
sem banco real, por escopo deliberado desta feature (ver PRD/TRD).

```python
from __future__ import annotations

from application.ports.task_repository import TaskRepository
from domain.task import Task


class InMemoryTaskRepository(TaskRepository):
    """Test/demo implementation of TaskRepository backed by a dict."""

    def __init__(self) -> None:
        self._tasks: dict[str, Task] = {}

    def save(self, task: Task) -> None:
        self._tasks[task.id] = task

    def get(self, task_id: str) -> Task | None:
        return self._tasks.get(task_id)

    def list_all(self) -> list[Task]:
        return list(self._tasks.values())
```

## Adapter inbound (`src/adapters/inbound/cli.py`)

Aciona os casos de uso a partir de argumentos de linha de comando (`argparse`) — a única parte do
sistema que sabe formatar saída para o usuário final.

```python
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
```

## Testes

### Unit — domínio (`tests/unit/domain/test_task.py`)

Testa a regra de negócio isolada, sem nenhum dublê — não há dependência para isolar.

```python
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
```

### Unit — aplicação (`tests/unit/application/test_create_task.py`)

Testa o caso de uso contra um dublê do port (`FakeTaskRepository`), nunca a implementação real —
mantém a camada de aplicação isolada de infraestrutura de verdade.

```python
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
```

### Integration (`tests/integration/test_in_memory_task_repository.py`)

Testa a implementação **real** do adapter contra o contrato do port — diferente do teste unitário
acima, aqui não há dublê nenhum.

```python
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
```

(`tests/e2e/test_cli.py` exercitava a CLI de ponta a ponta, chamando `run()` diretamente com os
argumentos de linha de comando e um `InMemoryTaskRepository` real — sem nenhum dublê, como convém
a um teste e2e.)

## Packaging, lint e cobertura (`pyproject.toml`)

Gerenciador de pacotes `pip`/`setuptools`, `pytest`+`pytest-cov` para testes/cobertura, `ruff` para
lint, gate de cobertura de 80% configurado em `[tool.coverage.report]`.

```toml
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "projeto-base-ia"
version = "0.1.0"
description = "Template SDD (Spec-Driven Development) com ports & adapters, TDD e pipeline de CI/CD."
requires-python = ">=3.11"
dependencies = []

[tool.setuptools.packages.find]
where = ["src"]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=5.0",
    "ruff>=0.6",
]

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
fail_under = 80
show_missing = true
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.:",
]

[tool.ruff]
line-length = 100
src = ["src", "tests"]

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]
```

## Docker (`infra/docker/Dockerfile`)

Build multi-stage: a imagem final não carrega a toolchain de build, só o runtime necessário, e
roda como usuário não-root.

```dockerfile
# Build multi-stage: a imagem final não carrega toolchain de build, só o runtime necessário.

FROM python:3.11-slim AS builder

WORKDIR /build

COPY pyproject.toml ./
COPY src ./src

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir .

FROM python:3.11-slim AS runtime

RUN useradd --create-home --uid 1000 appuser
COPY --from=builder /opt/venv /opt/venv
COPY src /app/src

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app/src" \
    PYTHONUNBUFFERED="1"

WORKDIR /app
USER appuser

ENTRYPOINT ["python", "-m", "adapters.inbound.cli"]
CMD ["list"]
```

`infra/docker/docker-compose.yml` só subia o próprio serviço, buildado a partir desse Dockerfile:

```yaml
services:
  task-cli:
    build:
      context: ../..
      dockerfile: infra/docker/Dockerfile
    image: projeto-base-ia-example:local
    command: ["list"]
```

`infra/terraform/` era um esqueleto ilustrativo de ECR + ECS Fargate na AWS — `variables.tf`
definia entradas como `environment`, `container_image`, `container_cpu`/`container_memory`, e um
segredo de aplicação já nascendo marcado `sensitive = true`:

```hcl
variable "app_secrets" {
  description = "Segredos de aplicação injetados como variáveis de ambiente do container."
  type        = map(string)
  default     = {}
  sensitive   = true
}
```

## CI (`.github/workflows/ci.yml`)

Lint, testes com cobertura, e build (sem push) da imagem Docker — falha o pipeline se a cobertura
cair abaixo do gate de 80% configurado em `pyproject.toml`.

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  lint-and-test:
    name: Lint, testes e cobertura (gate 80%)
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configurar Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: "pip"

      - name: Instalar dependências
        run: python -m pip install --upgrade pip && pip install -e ".[dev]"

      - name: Lint (ruff)
        run: ruff check src tests

      - name: Testes + cobertura (gate 80%, ver pyproject.toml)
        run: pytest --cov=src --cov-report=term-missing --cov-report=xml

      - name: Upload do relatório de cobertura
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage.xml

  docker-build:
    name: Build da imagem Docker
    runs-on: ubuntu-latest
    needs: lint-and-test

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build (sem push — só valida que a imagem builda)
        uses: docker/build-push-action@v6
        with:
          context: .
          file: infra/docker/Dockerfile
          push: false
```

## CD (`.github/workflows/cd.yml`)

Disparado pelo término bem-sucedido do CI em `main` (nunca por push direto) ou manualmente
(`workflow_dispatch`, escolhendo o ambiente): build + push da imagem para o ECR, `terraform plan`,
e um `terraform apply` gated por ambiente protegido do GitHub (exige aprovação manual antes de
rodar).

```yaml
name: CD

on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: "Ambiente de destino"
        required: true
        default: "staging"
        type: choice
        options: [staging, production]

jobs:
  build-and-push:
    name: Build e push da imagem
    runs-on: ubuntu-latest
    if: >
      github.event_name == 'workflow_dispatch' ||
      (github.event.workflow_run.conclusion == 'success')
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE_ARN }}
          aws-region: ${{ vars.AWS_REGION }}
      - uses: aws-actions/amazon-ecr-login@v2
        id: ecr-login
      - run: |
          docker build -f infra/docker/Dockerfile -t "$REGISTRY/$REPOSITORY:$TAG" .
          docker push "$REGISTRY/$REPOSITORY:$TAG"

  terraform-plan:
    needs: build-and-push
    # terraform init / plan em infra/terraform, artefato do plano enviado para o próximo job

  terraform-apply:
    needs: terraform-plan
    environment: ${{ inputs.environment || 'staging' }}  # gate: aprovação manual no GitHub
    # terraform init / apply do plano baixado do job anterior
```

(Trecho de `terraform-plan`/`terraform-apply` condensado aqui — a mecânica central é o gate por
`environment` protegido do GitHub antes de `terraform apply`, que exige aprovação manual;
`terraform-plan` sempre roda, `terraform-apply` só depois de aprovado.)
