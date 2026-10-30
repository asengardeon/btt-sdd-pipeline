#!/usr/bin/env python3
"""Diagnóstico rápido: o osv-scanner (https://github.com/google/osv-scanner) está instalado?

Não é um gate — nenhuma etapa do pipeline depende de osv-scanner para funcionar
(docs/TOOLING.md, seção "Ferramentas de análise estática e segurança"). O `security-engineer`
usa este binário, quando disponível, como primeira passada determinística na área
"Dependências"; identificar manualmente o que o scanner não cobrir continua sendo seu trabalho.

Uso:
    python scripts/check-osv-scanner.py

Saída: sempre código 0 (diagnóstico informativo, nunca bloqueante).
"""

from __future__ import annotations

import shutil
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def main() -> int:
    binario = shutil.which("osv-scanner")
    print(
        f"Binário osv-scanner no PATH: {'sim (' + binario + ')' if binario else 'não encontrado'}"
    )

    if not binario:
        print(
            "\nosv-scanner não está instalado. Instalação (uma vez por máquina, não por projeto):\n"
            "  brew install osv-scanner                        # macOS / Linux\n"
            "  go install github.com/google/osv-scanner/cmd/osv-scanner@v1\n"
            "\nVer docs/TOOLING.md para detalhe completo e a convenção de uso pelo "
            "security-engineer."
        )
        return 0

    try:
        versao = subprocess.run(
            ["osv-scanner", "--version"], capture_output=True, text=True, timeout=5, check=False
        ).stdout.strip()
        print(f"Versão: {versao or '(sem saída)'}")
    except (OSError, subprocess.TimeoutExpired):
        print("Versão: não foi possível executar `osv-scanner --version`")

    print(
        "\nLembrete: isto é só diagnóstico — nenhuma etapa do pipeline bloqueia por osv-scanner "
        "ausente (docs/TOOLING.md)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
