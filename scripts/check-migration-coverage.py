#!/usr/bin/env python3
"""Garante que toda versão de formato nova de um artefato tem regra de migração registrada.

Quando um artefato gerado pelo pipeline (`specs/_template/<artefato>.template.md`, ou um split em
`specs/_template/reviews/<artefato>/` ou `specs/_template/<artefato>/`) ganha uma versão de
formato nova que quebra a estrutura do arquivo (`<!-- sdd-format-version: N -->` maior do que a
versão anterior conhecida), a regra de migração correspondente em
`.claude/skills/sdd-migrate/migrations/` é **obrigatória no mesmo commit/PR** — não é opcional,
não fica para depois (`docs/MICRO-CONTEXT.md`, seção 3). Nada, até este script, verificava isso
mecanicamente.

Hoje a convenção tem duas camadas por artefato: o template de arquivo único em
`specs/_template/<artefato>.template.md` (a versão mais antiga conhecida daquele artefato) e,
quando o artefato migrou para um formato split, um `index.template.md` que carrega a versão
atual — em `specs/_template/reviews/<artefato>/` para split por rodada (os 5 artefatos de
revisão, `docs/MICRO-CONTEXT.md` seção 2) ou direto em `specs/_template/<artefato>/` para split
por tópico (`prd`, `trd`, seção 2b). Este script lê o marcador de ambas as camadas quando
existirem e confirma que existe um arquivo
`.claude/skills/sdd-migrate/migrations/<artefato>-v<origem>-to-v<destino>.md` cobrindo cada salto
de versão — hoje sempre `v1 → v2` para os 7 artefatos com split, mas o script generaliza para
qualquer `N → N+1` se uma terceira versão nascer no futuro.

Além dessas duas camadas, existe um terceiro tipo de artefato: docs de `docs/` gerados por um
agente sem template em `specs/_template/` (a estrutura exata vive inline no arquivo-filho do
próprio agente). Esses entram num registro próprio (`DOCS_LEVEL_ARTIFACTS`) em vez de `Glob`,
já que não há como descobri-los por convenção de caminho — hoje são `docs-map`
(`.claude/agents/tech-writer/mapa-de-documentacao.md`) e `features`
(`.claude/agents/tech-writer/catalogo-de-features.md`), ambos só em `v1` ainda (sem segunda
camada, logo sem salto a cobrir) — contam para o total verificado, mas um bump futuro de
qualquer um dos dois precisa primeiro de uma entrada nova neste script antes de poder ser
verificado mecanicamente (não há uma segunda camada física automática como o split por rodada).

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

# Artefatos de docs/ gerados por um agente sem template em specs/_template/ — a estrutura exata
# vive inline no arquivo-filho do agente, dentro de um bloco ```markdown. Registro manual porque
# não há convenção de caminho para descobri-los por Glob (docs/MICRO-CONTEXT.md, seção 3).
DOCS_LEVEL_ARTIFACTS = {
    "docs-map": ROOT / ".claude" / "agents" / "tech-writer" / "mapa-de-documentacao.md",
    "features": ROOT / ".claude" / "agents" / "tech-writer" / "catalogo-de-features.md",
}

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
    """Artefato -> versão, a partir de index.template.md num diretório split.

    Duas camadas de split existem hoje (`docs/MICRO-CONTEXT.md`, seções 2 e 2b): split por rodada
    em `specs/_template/reviews/<artefato>/index.template.md` (os 5 artefatos de revisão) e split
    por tópico direto em `specs/_template/<artefato>/index.template.md` (`prd`, `trd`) — mesma
    detecção, só muda a profundidade do diretório.
    """
    versions = {}
    if REVIEWS_DIR.is_dir():
        for sub in REVIEWS_DIR.iterdir():
            if not sub.is_dir():
                continue
            v = read_version(sub / "index.template.md")
            if v is not None:
                versions[sub.name] = v
    for sub in TEMPLATES_DIR.iterdir():
        if not sub.is_dir() or sub.name == "reviews":
            continue
        v = read_version(sub / "index.template.md")
        if v is not None:
            versions[sub.name] = v
    return versions


def read_version_from_code_block(path: Path) -> int | None:
    """Lê a versão na primeira linha dentro do bloco ```markdown (artefato de docs/ sem template)."""
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError:
        return None
    in_block = False
    for line in lines:
        stripped = line.strip()
        if not in_block:
            if stripped == "```markdown":
                in_block = True
            continue
        if not stripped:
            continue
        m = VERSION_RE.match(stripped)
        return int(m.group(1)) if m else None
    return None


def collect_docs_level_versions() -> dict[str, int]:
    """Artefato -> versão, a partir do registro DOCS_LEVEL_ARTIFACTS."""
    versions = {}
    for artefato, path in DOCS_LEVEL_ARTIFACTS.items():
        v = read_version_from_code_block(path)
        if v is not None:
            versions[artefato] = v
    return versions


def main() -> int:
    single = collect_single_file_versions()
    single.update(collect_docs_level_versions())
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
