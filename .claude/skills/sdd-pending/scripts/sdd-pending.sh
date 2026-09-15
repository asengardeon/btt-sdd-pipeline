#!/usr/bin/env bash
# Lista os itens "VALIDAR DEPOIS" com status "pendente" e as tarefas ainda não
# implementadas (tabela "Decomposição de tarefas e dependências" do TRD) em
# todas as features de specs/ e em docs/BASELINE.md, sem precisar ler cada
# artefato inteiro no contexto do agente. Usado por .claude/skills/sdd-pending.
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
      status4 = cols[4]; gsub(/^\*+/, "", status4)
      if (n >= 4 && cols[1] != "ID" && cols[1] !~ /^-+$/ && status4 ~ /^[Pp]endente/) {
        printf("%s\t%s\t%s\t%s\n", artefato, cols[1], cols[2], cols[3])
      }
    }
  ' "$2"
}

# Colapsa linhas que só remetem a uma rodada anterior sem conteúdo novo — mantém
# só a ocorrência mais informativa por (feature, pergunta). Lê tab-separated
# feature\tartefato\tid\tpergunta\tcontexto da entrada e devolve o mesmo formato,
# deduplicado, na ordem de primeira aparição de cada chave.
dedupe_rows() {
  awk -F'\t' '
    function is_referencial(s) {
      return (s ~ /ver rodada|ver acima|mesma pend|repetid|sem novidade|inalterad|ja citad|já citad/)
    }
    {
      key = $1 SUBSEP $4
      if (!(key in seen)) {
        seen[key] = 1
        order[++n] = key
        kept[key] = $0
        keptctx[key] = $5
      } else {
        cur_ref = is_referencial(keptctx[key])
        new_ref = is_referencial($5)
        # Só substitui a linha guardada quando a nova traz conteúdo novo
        # (não-referencial) e a guardada era só uma referência à rodada
        # anterior; nos demais casos mantém a primeira ocorrência.
        if (cur_ref && !new_ref) {
          kept[key] = $0
          keptctx[key] = $5
        }
      }
    }
    END {
      for (i = 1; i <= n; i++) print kept[order[i]]
    }
  '
}

# Extrai da tabela "Decomposição de tarefas e dependências" do TRD as linhas
# cujo Status ainda não chegou a "implementado" (pendente/em andamento/
# bloqueado). As colunas "Status"/"Issue GitHub" são resolvidas pelo texto do
# cabeçalho, não por posição fixa — a ordem das demais colunas já variou entre
# TRDs reais (`docs/QUALITY-GATES.md` não fixa uma ordem além de exigir as
# duas), e um índice fixo já fez esta função nunca encontrar nenhuma tarefa
# pendente de verdade (issue #189). ID/Tarefa/Trilha continuam nas 3 primeiras
# colunas, únicas cuja ordem o restante do pipeline já depende.
print_task_rows() {
  awk '
    BEGIN { insec = 0; header_seen = 0; status_idx = 0; issue_idx = 0 }
    /^## .*Decomposição de tarefas e dependências/ { insec = 1; next }
    /^## / && insec == 1 { insec = 0 }
    insec == 1 && /^\|/ {
      if ($0 ~ /^\|[-|[:space:]]+\|?$/) next
      line = $0
      gsub(/^\| */, "", line); gsub(/ *\|$/, "", line)
      n = split(line, cols, "|")
      for (i = 1; i <= n; i++) { gsub(/^ +| +$/, "", cols[i]) }
      if (!header_seen) {
        header_seen = 1
        for (i = 1; i <= n; i++) {
          if (cols[i] == "Status") status_idx = i
          if (cols[i] == "Issue GitHub") issue_idx = i
        }
        next
      }
      if (status_idx > 0 && cols[1] != "") {
        status = tolower(cols[status_idx])
        gsub(/^\*+/, "", status)
        if (status ~ /^(pendente|em andamento|bloqueado)/) {
          issue = (issue_idx > 0) ? cols[issue_idx] : ""
          printf("%s\t%s\t%s\t%s\t%s\n", cols[1], cols[2], cols[3], cols[status_idx], issue)
        }
      }
    }
  ' "$1"
}

ROWS=""
TASK_ROWS=""
SPECS_SEM_TRD=""

collect_rows() {
  # $1 = feature exibida, $2 = artefato, $3 = arquivo
  while IFS=$'\t' read -r artefato id pergunta contexto; do
    [ -z "$id" ] && continue
    ROWS="${ROWS}${1}"$'\t'"${artefato}"$'\t'"${id}"$'\t'"${pergunta}"$'\t'"${contexto}"$'\n'
  done < <(print_rows "$2" "$3")
}

collect_task_rows() {
  # $1 = feature exibida, $2 = arquivo trd.md
  while IFS=$'\t' read -r id tarefa trilha status issue; do
    [ -z "$id" ] && continue
    TASK_ROWS="${TASK_ROWS}${1}"$'\t'"${id}"$'\t'"${tarefa}"$'\t'"${trilha}"$'\t'"${status}"$'\t'"${issue}"$'\n'
  done < <(print_task_rows "$2")
}

if [ -f "docs/BASELINE.md" ]; then
  collect_rows "(baseline)" "BASELINE" "docs/BASELINE.md"
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
      collect_rows "$slug" "$f" "$file"
    done

    trd_file="${dir}trd.md"
    if [ -f "$trd_file" ]; then
      collect_task_rows "$slug" "$trd_file"
    elif [ -f "${dir}prd.md" ]; then
      SPECS_SEM_TRD="${SPECS_SEM_TRD}${slug}"$'\n'
    fi
  done
fi

printf '%-28s | %-16s | %-6s | %-42s | %s\n' "Feature" "Artefato" "ID" "Pergunta" "Contexto"
printf -- '-%.0s' $(seq 1 130); echo

found=0
if [ -n "$ROWS" ]; then
  while IFS=$'\t' read -r feature artefato id pergunta contexto; do
    [ -z "$feature" ] && continue
    found=1
    printf '%-28s | %-16s | %-6s | %-42s | %s\n' "$feature" "$artefato" "$id" "$pergunta" "$contexto"
  done < <(printf '%s' "$ROWS" | dedupe_rows)
fi

if [ "$found" = "0" ]; then
  echo "Nenhuma pendência VALIDAR DEPOIS em aberto."
fi

echo
echo "Tarefas ainda não implementadas (tabela de decomposição do TRD):"
printf '%-28s | %-6s | %-42s | %-14s | %-14s | %s\n' "Feature" "ID" "Tarefa" "Trilha" "Status" "Issue"
printf -- '-%.0s' $(seq 1 130); echo

found_task=0
if [ -n "$TASK_ROWS" ]; then
  while IFS=$'\t' read -r feature id tarefa trilha status issue; do
    [ -z "$feature" ] && continue
    found_task=1
    printf '%-28s | %-6s | %-42s | %-14s | %-14s | %s\n' "$feature" "$id" "$tarefa" "$trilha" "$status" "$issue"
  done < <(printf '%s' "$TASK_ROWS")
fi

if [ "$found_task" = "0" ]; then
  echo "Nenhuma tarefa pendente de implementação nos TRDs existentes."
fi

if [ -n "$SPECS_SEM_TRD" ]; then
  echo
  echo "Specs com PRD aprovado mas sem TRD ainda (tarefas não decompostas): $(printf '%s' "$SPECS_SEM_TRD" | paste -sd ', ' -)"
fi
