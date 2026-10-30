#!/usr/bin/env python3
"""Diagnóstico rápido: o ast-grep (https://ast-grep.github.io) está instalado?

Não é um gate — nenhuma etapa do pipeline depende de ast-grep para funcionar (docs/TOOLING.md,
seção "Ferramentas de análise estática e segurança"). O `code-reviewer` usa este binário, quando
disponível, para buscar estruturalmente violação da regra da dependência (ports & adapters); a
verificação manual de importação continua obrigatória com ou sem ele.

Uso:
    python scripts/check-ast-grep.py

Saída: sempre código 0 (diagnóstico informativo, nunca bloqueante).
"""

from __future__ import annotations

import shutil
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def main() -> int:
    binario = shutil.which("ast-grep") or shutil.which("sg")
    print(f"Binário ast-grep no PATH: {'sim (' + binario + ')' if binario else 'não encontrado'}")

    if not binario:
        print(
            "\nast-grep não está instalado. Instalação (uma vez por máquina, não por projeto):\n"
            "  brew install ast-grep                           # macOS / Linux\n"
            "  cargo install ast-grep --locked\n"
            "  npm install -g @ast-grep/cli\n"
            "\nVer docs/TOOLING.md para detalhe completo e a convenção de uso pelo code-reviewer."
        )
        return 0

    try:
        versao = subprocess.run(
            [binario, "--version"], capture_output=True, text=True, timeout=5, check=False
        ).stdout.strip()
        print(f"Versão: {versao or '(sem saída)'}")
    except (OSError, subprocess.TimeoutExpired):
        print(f"Versão: não foi possível executar `{binario} --version`")

    print(
        "\nLembrete: isto é só diagnóstico — nenhuma etapa do pipeline bloqueia por ast-grep "
        "ausente (docs/TOOLING.md)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
