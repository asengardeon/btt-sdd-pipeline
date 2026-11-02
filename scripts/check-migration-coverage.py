#!/usr/bin/env python3
"""Garante que toda versão de formato nova de um artefato tem regra de migração registrada.

Quando um artefato gerado pelo pipeline (`specs/_template/<artefato>.template.md`, ou o split
físico em `specs/_template/reviews/<artefato>/`) ganha uma versão de formato nova que quebra a
estrutura do arquivo (`<!-- sdd-format-version: N -->` maior do que a versão anterior conhecida),
a regra de migração correspondente em `.claude/skills/sdd-migrate/migrations/` é **obrigatória
no mesmo commit/PR** — não é opcional, não fica para depois (`docs/MICRO-CONTEXT.md`, seção 3).
Nada, até este script, verificava isso mecanicamente.

Hoje a convenção tem duas camadas por artefato: o template de arquivo único em
`specs/_template/<artefato>.template.md` (a versão mais antiga conhecida daquele artefato) e,
quando o artefato migrou para o split físico por rodada, `specs/_template/reviews/<artefato>/`
(a versão atual). Este script lê o marcador de ambas as camadas quando existirem e confirma que
existe um arquivo `.claude/skills/sdd-migrate/migrations/<artefato>-v<origem>-to-v<destino>.md`
cobrindo cada salto de versão — hoje sempre `v1 → v2` para os 5 artefatos de revisão, mas o
script generaliza para qualquer `N → N+1` se uma terceira versão nascer no futuro.

Uso:
    python scripts/check-migration-coverage.py

Saída: código 0 se toda versão nova tem regra registrada, 1 se falta alguma.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = ROOT / "specs" / "_template"
REVIEWS_DIR = TEMPLATES_DIR / "reviews"
MIGRATIONS_DIR = ROOT / ".claude" / "skills" / "sdd-migrate" / "migrations"

VERSION_RE = re.compile(r"<!--\s*sdd-format-version:\s*(\d+)\s*-->")


def read_version(path: Path) -> int | None:
    """Lê a versão declarada na primeira linha não vazia do arquivo, ou None se ausente."""
    try:
        with path.open(encoding="utf-8") as fh:
            for line in fh:
                stripped = line.strip()
                if not stripped:
                    continue
                m = VERSION_RE.match(stripped)
                return int(m.group(1)) if m else None
    except FileNotFoundError:
        return None
    return None


def collect_single_file_versions() -> dict[str, int]:
    """Artefato -> versão, a partir de specs/_template/<artefato>.template.md."""
    versions = {}
    for path in TEMPLATES_DIR.glob("*.template.md"):
        artefato = path.name[: -len(".template.md")]
        v = read_version(path)
        if v is not None:
            versions[artefato] = v
    return versions


def collect_split_versions() -> dict[str, int]:
    """Artefato -> versão, a partir de specs/_template/reviews/<artefato>/index.template.md."""
    versions = {}
    if not REVIEWS_DIR.is_dir():
        return versions
    for sub in REVIEWS_DIR.iterdir():
        if not sub.is_dir():
            continue
        index = sub / "index.template.md"
        v = read_version(index)
        if v is not None:
            versions[sub.name] = v
    return versions


def main() -> int:
    single = collect_single_file_versions()
    split = collect_split_versions()

    artefatos = sorted(set(single) | set(split))
    missing: list[tuple[str, int, int]] = []
    inconsistent: list[str] = []

    for artefato in artefatos:
        v_old = single.get(artefato)
        v_new = split.get(artefato)
        if v_old is None or v_new is None:
            # Só uma camada existe (nunca migrou, ou nasceu direto na forma split) — sem salto
            # de versão para cobrir.
            continue
        if v_new <= v_old:
            inconsistent.append(
                f"{artefato}: versão do split ({v_new}) não é maior que a do arquivo único "
                f"({v_old})"
            )
            continue
        for n in range(v_old, v_new):
            regra = MIGRATIONS_DIR / f"{artefato}-v{n}-to-v{n + 1}.md"
            if not regra.is_file():
                missing.append((artefato, n, n + 1))

    if inconsistent:
        print("Inconsistência de versão (corrija antes de checar cobertura de migração):")
        for linha in inconsistent:
            print(f"  {linha}")
        print()

    if missing:
        print(f"Regra de migração faltando ({len(missing)}):")
        for artefato, v_old, v_new in missing:
            print(
                f"  {artefato}: v{v_old} → v{v_new} sem "
                f".claude/skills/sdd-migrate/migrations/{artefato}-v{v_old}-to-v{v_new}.md"
            )
        print()
        print(
            "Toda versão de formato nova que quebra a estrutura do arquivo exige a regra de "
            "migração correspondente no mesmo commit/PR (docs/MICRO-CONTEXT.md, seção 3) — "
            "crie o arquivo faltando antes de seguir."
        )
        return 1

    if inconsistent:
        return 1

    print(f"Artefatos verificados: {len(artefatos)}")
    print("Toda versão nova tem regra de migração registrada.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
