#!/usr/bin/env python3
"""Diagnóstico rápido: o hadolint (https://github.com/hadolint/hadolint) está instalado?

Não é um gate — nenhuma etapa do pipeline depende de hadolint para funcionar (docs/TOOLING.md,
seção "Ferramentas de análise estática e segurança"). O `sre` usa este binário, quando
disponível, como primeira passada determinística na área "Docker"; a confirmação manual do
checklist continua obrigatória com ou sem ele.

Uso:
    python scripts/check-hadolint.py

Saída: sempre código 0 (diagnóstico informativo, nunca bloqueante).
"""

from __future__ import annotations

import shutil
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def main() -> int:
    binario = shutil.which("hadolint")
    print(f"Binário hadolint no PATH: {'sim (' + binario + ')' if binario else 'não encontrado'}")

    if not binario:
        print(
            "\nhadolint não está instalado. Instalação (uma vez por máquina, não por projeto):\n"
            "  brew install hadolint                           # macOS / Linux\n"
            "  winget install Hadolint.Hadolint                # Windows\n"
            "\nVer docs/TOOLING.md para detalhe completo e a convenção de uso pelo sre."
        )
        return 0

    try:
        versao = subprocess.run(
            ["hadolint", "--version"], capture_output=True, text=True, timeout=5, check=False
        ).stdout.strip()
        print(f"Versão: {versao or '(sem saída)'}")
    except (OSError, subprocess.TimeoutExpired):
        print("Versão: não foi possível executar `hadolint --version`")

    print(
        "\nLembrete: isto é só diagnóstico — nenhuma etapa do pipeline bloqueia por hadolint "
        "ausente (docs/TOOLING.md)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
