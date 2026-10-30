#!/usr/bin/env python3
"""Diagnóstico rápido: o gitleaks (https://github.com/gitleaks/gitleaks) está instalado?

Não é um gate — nenhuma etapa do pipeline depende de gitleaks para funcionar (docs/TOOLING.md,
seção "Ferramentas de análise estática e segurança"). O `security-engineer` usa este binário,
quando disponível, como primeira passada determinística na área "Gestão de segredos na
aplicação"; a leitura manual continua obrigatória com ou sem ele.

Uso:
    python scripts/check-gitleaks.py

Saída: sempre código 0 (diagnóstico informativo, nunca bloqueante).
"""

from __future__ import annotations

import shutil
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def main() -> int:
    binario = shutil.which("gitleaks")
    print(f"Binário gitleaks no PATH: {'sim (' + binario + ')' if binario else 'não encontrado'}")

    if not binario:
        print(
            "\ngitleaks não está instalado. Instalação (uma vez por máquina, não por projeto):\n"
            "  brew install gitleaks                          # macOS / Linux\n"
            "  winget install gitleaks.gitleaks               # Windows\n"
            "  go install github.com/gitleaks/gitleaks/v8@latest\n"
            "\nVer docs/TOOLING.md para detalhe completo e a convenção de uso pelo "
            "security-engineer."
        )
        return 0

    try:
        versao = subprocess.run(
            ["gitleaks", "version"], capture_output=True, text=True, timeout=5, check=False
        ).stdout.strip()
        print(f"Versão: {versao or '(sem saída)'}")
    except (OSError, subprocess.TimeoutExpired):
        print("Versão: não foi possível executar `gitleaks version`")

    print(
        "\nLembrete: isto é só diagnóstico — nenhuma etapa do pipeline bloqueia por gitleaks "
        "ausente (docs/TOOLING.md)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
