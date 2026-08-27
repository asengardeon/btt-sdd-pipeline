#!/usr/bin/env bash
# Compara os casos de uso listados na seção 6 (Casos de uso) do TRD de uma
# feature contra o código real implementado, sem precisar reler o TRD inteiro
# e grepar classe por classe manualmente. Usado por
# .claude/skills/sdd-gap-report.
#
# Uso: scripts/sdd-gap-report.sh <slug> [caminho-busca ...]
#   slug            — obrigatório: specs/<slug>/trd.md precisa existir.
#   caminho-busca   — opcional, um ou mais diretórios; substitui a detecção
#                     automática (src/ e, se existir, frontend/) quando o
#                     projeto usa outra convenção de pastas (ex.:
#                     src/app/Application/UseCases/ num projeto Laravel).
#
# Saída: aproximação best-effort via grep/awk sobre a convenção de
# formatação da tabela "Critério de aceite (PRD) | Caso de uso | Ports
# usados" de specs/_template/trd.template.md. Se a tabela fugir muito do
# formato padrão, isso é sinalizado e o TRD precisa ser lido manualmente.
#
# Nota sobre frontend: nenhum template deste pipeline define hoje uma tabela
# equivalente de "telas/rotas" para o frontend (é uma decisão do `architect`,
# caso a caso, não um formato fixo) — por isso este script não tenta parsear
# uma. Em compensação, frontend/ entra por padrão nas raízes de busca, então
# um caso de uso cujo nome também aparece do lado do frontend (ex.: client
# de API com o mesmo nome do caso de uso) ainda é encontrado.

SLUG="${1:-}"
shift || true
SEARCH_PATHS=("$@")

if [ -z "$SLUG" ]; then
  echo "Uso: sdd-gap-report.sh <slug> [caminho-busca ...]"
  exit 1
fi

TRD="specs/$SLUG/trd.md"
if [ ! -f "$TRD" ]; then
  echo "TRD não encontrado: $TRD"
  exit 1
fi

roots=()
if [ ${#SEARCH_PATHS[@]} -gt 0 ]; then
  roots=("${SEARCH_PATHS[@]}")
else
  [ -d "src" ] && roots+=("src")
  [ -d "frontend" ] && roots+=("frontend")
fi
if [ ${#roots[@]} -eq 0 ]; then
  echo "Nenhum diretório de código encontrado (src/ ou frontend/) e nenhum caminho-busca informado."
  exit 1
fi

EXCLUDE_DIRS=(.git node_modules vendor dist build .venv venv __pycache__ .next target)
EXCLUDE_ARGS=()
for d in "${EXCLUDE_DIRS[@]}"; do EXCLUDE_ARGS+=(--exclude-dir="$d"); done

extract_rows() {
  # Linhas da tabela da seção 6 (Casos de uso) do TRD: coluna 1 = critério de
  # aceite, coluna 2 = caso de uso. Ignora cabeçalho e linha separadora.
  awk '
    BEGIN { insec = 0 }
    /^## 6\. Casos de uso/ { insec = 1; next }
    insec == 1 && /^## / { insec = 0 }
    insec == 1 && /^\|/ {
      line = $0
      gsub(/^\| */, "", line); gsub(/ *\|$/, "", line)
      n = split(line, cols, "|")
      for (i = 1; i <= n; i++) { gsub(/^ +| +$/, "", cols[i]) }
      if (n >= 2 && cols[2] !~ /^-+$/ && tolower(cols[2]) !~ /^caso de uso$/) {
        printf("%s\t%s\n", cols[1], cols[2])
      }
    }
  ' "$TRD"
}

printf '%-38s | %-38s | %-12s | %s\n' "Caso de uso" "Critério de aceite (US)" "Implementado" "Evidência"
printf -- '-%.0s' $(seq 1 130); echo

any=0
while IFS=$'\t' read -r crit caso; do
  [ -z "$caso" ] && continue
  any=1

  classname="$(printf '%s' "$caso" | grep -oE '`[^`]+`' | head -1 | tr -d '`')"
  [ -z "$classname" ] && classname="$caso"

  match=""
  for r in "${roots[@]}"; do
    [ -d "$r" ] || continue
    hit="$(grep -rlF "${EXCLUDE_ARGS[@]}" -- "$classname" "$r" 2>/dev/null \
      | grep -viE '/tests?/|\.spec\.|_test\.|\.test\.' | head -1)"
    if [ -n "$hit" ]; then match="$hit"; break; fi
  done

  if [ -n "$match" ]; then impl="sim"; else impl="NÃO"; fi
  printf '%-38s | %-38s | %-12s | %s\n' "$classname" "$crit" "$impl" "${match:-(nenhum arquivo encontrado)}"
done < <(extract_rows)

if [ "$any" = "0" ]; then
  echo
  echo "Nenhuma linha reconhecida na seção 6 (Casos de uso) de $TRD — a tabela pode ter fugido do formato padrão (specs/_template/trd.template.md); leia o TRD manualmente."
  exit 0
fi

echo
echo "Raízes de busca usadas: ${roots[*]}"
echo "\"NÃO\" significa que o nome do caso de uso não apareceu (via grep) em nenhum arquivo dessas raízes — confirme manualmente antes de tratar como não implementado, o grep não entende refactors que renomeiam a classe."
