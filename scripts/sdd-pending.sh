#!/usr/bin/env bash
# Lista os itens "VALIDAR DEPOIS" com status "pendente" em todas as features de
# specs/ e em docs/BASELINE.md, sem precisar ler cada artefato inteiro no
# contexto do agente. Usado por .claude/skills/sdd-pending.
#
# Uso: scripts/sdd-pending.sh [slug]
#   slug (opcional) — mostra só aquela feature.

SPECS_DIR="specs"
FILTER="${1:-}"
FILES=(prd.md trd.md code-review.md qa-report.md security-review.md sre-review.md)

print_rows() {
  # $1 = rótulo do artefato exibido na tabela, $2 = caminho do arquivo
  awk -v artefato="$1" '
    BEGIN { insec = 0 }
    /^## .*VALIDAR DEPOIS/ { insec = 1; next }
    /^## / && insec == 1 { insec = 0 }
    insec == 1 && /^\|/ {
      line = $0
      gsub(/^\| */, "", line); gsub(/ *\|$/, "", line)
      n = split(line, cols, "|")
      for (i = 1; i <= n; i++) { gsub(/^ +| +$/, "", cols[i]) }
      if (n >= 4 && cols[1] != "ID" && cols[1] !~ /^-+$/ && cols[4] ~ /pendente/) {
        printf("%s\t%s\t%s\t%s\n", artefato, cols[1], cols[2], cols[3])
      }
    }
  ' "$2"
}

printf '%-28s | %-16s | %-6s | %-42s | %s\n' "Feature" "Artefato" "ID" "Pergunta" "Contexto"
printf -- '-%.0s' $(seq 1 130); echo

found=0

if [ -f "docs/BASELINE.md" ]; then
  while IFS=$'\t' read -r artefato id pergunta contexto; do
    [ -z "$id" ] && continue
    found=1
    printf '%-28s | %-16s | %-6s | %-42s | %s\n' "(baseline)" "$artefato" "$id" "$pergunta" "$contexto"
  done < <(print_rows "BASELINE" "docs/BASELINE.md")
fi

if [ -d "$SPECS_DIR" ]; then
  for dir in "$SPECS_DIR"/*/; do
    [ -d "$dir" ] || continue
    slug="$(basename "$dir")"
    [ "$slug" = "_template" ] && continue
    if [ -n "$FILTER" ] && [ "$slug" != "$FILTER" ]; then continue; fi

    for f in "${FILES[@]}"; do
      file="${dir}${f}"
      [ -f "$file" ] || continue
      while IFS=$'\t' read -r artefato id pergunta contexto; do
        [ -z "$id" ] && continue
        found=1
        printf '%-28s | %-16s | %-6s | %-42s | %s\n' "$slug" "$artefato" "$id" "$pergunta" "$contexto"
      done < <(print_rows "$f" "$file")
    done
  done
fi

if [ "$found" = "0" ]; then
  echo "Nenhuma pendência VALIDAR DEPOIS em aberto."
fi
