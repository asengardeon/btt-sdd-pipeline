#!/usr/bin/env python3
"""Diagnóstico rápido: o rtk (https://github.com/rtk-ai/rtk) está instalado e configurado?

Não é um gate — nenhuma etapa do pipeline depende de rtk para funcionar (docs/TOOLING.md). Este
script só ajuda a investigar por que uma sessão está consumindo mais tokens do que o esperado em
etapas com muito comando de shell (QA, SRE, revisão de código), reportando o que falta sem travar
nada.

Uso:
    python scripts/check-rtk.py

Saída: sempre código 0 (diagnóstico informativo, nunca bloqueante).
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def rtk_binario() -> str | None:
    return shutil.which("rtk")


def hook_configurado(caminho_settings: Path) -> bool:
    if not caminho_settings.exists():
        return False
    try:
        conteudo = caminho_settings.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return False
    return "rtk" in conteudo and "PreToolUse" in conteudo


def main() -> int:
    binario = rtk_binario()
    print(f"Binário rtk no PATH: {'sim (' + binario + ')' if binario else 'não encontrado'}")

    if not binario:
        print(
            "\nrtk não está instalado. Instalação (uma vez por máquina, não por projeto):\n"
            "  brew install rtk                  # macOS / Linux\n"
            "  winget install rtk-ai.rtk         # Windows\n"
            "  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/"
            "install.sh | sh\n"
            "\nDepois: rtk init -g   (registra o hook global do Claude Code)\n"
            "\nVer docs/TOOLING.md para detalhe completo."
        )
        return 0

    try:
        versao = subprocess.run(
            ["rtk", "--version"], capture_output=True, text=True, timeout=5, check=False
        ).stdout.strip()
        print(f"Versão: {versao or '(sem saída)'}")
    except (OSError, subprocess.TimeoutExpired):
        print("Versão: não foi possível executar `rtk --version`")

    candidatos_settings = [
        Path.home() / ".claude" / "settings.json",
        Path.cwd() / ".claude" / "settings.json",
        Path.cwd() / ".claude" / "settings.local.json",
    ]
    algum_configurado = any(hook_configurado(c) for c in candidatos_settings)

    if algum_configurado:
        print("Hook PreToolUse do rtk: encontrado em pelo menos um settings.json conhecido.")
    else:
        print(
            "Hook PreToolUse do rtk: não encontrado nos settings.json conhecidos "
            f"({', '.join(str(c) for c in candidatos_settings)}).\n"
            "Se o binário já está instalado, rode `rtk init -g` para registrar o hook."
        )

    print(
        "\nLembrete: isto é só diagnóstico — nenhuma etapa do pipeline bloqueia por rtk ausente "
        "(docs/TOOLING.md)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
