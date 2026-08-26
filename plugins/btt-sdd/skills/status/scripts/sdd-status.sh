#!/usr/bin/env bash
# Resumo do estágio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado pela skill deste plugin (skills/status/,
# comando /btt-sdd:status) — equivalente a .claude/skills/sdd-status (/sdd-status).
#
# Uso: scripts/sdd-status.sh [slug]
#   slug (opcional) — mostra só aquela feature.
#
# Saída: aproximação best-effort via grep/awk sobre a convenção de formatação
# dos templates em specs/_template/. Se um artefato fugir muito do formato
# padrão (veredito sem **negrito**, checkbox fora do padrão), o agente que
# chamou este script deve cair de volta para ler o arquivo inteiro.

SPECS_DIR="specs"
FILTER="${1:-}"

STAGES=(prd trd code-review qa-report security-review sre-review)

label() {
  case "$1" in
    prd) echo "PRD" ;;
    trd) echo "TRD" ;;
    code-review) echo "Code review" ;;
    qa-report) echo "QA" ;;
    security-review) echo "Segurança" ;;
    sre-review) echo "SRE" ;;
  esac
}

next_cmd() {
  case "$1" in
    prd) echo "/btt-sdd:trd" ;;
    trd) echo "/btt-sdd:implement" ;;
    code-review) echo "/btt-sdd:qa" ;;
    qa-report) echo "/btt-sdd:security" ;;
    security-review) echo "/btt-sdd:sre" ;;
    sre-review) echo "(pipeline concluído)" ;;
  esac
}

if [ ! -d "$SPECS_DIR" ]; then
  echo "Nenhum diretório '$SPECS_DIR/' encontrado a partir do diretório atual."
  exit 0
fi

printf '%-32s | %-30s | %-26s | %-4s | %s\n' "Feature" "Etapa atual" "Próximo comando" "Pend" "Revalidar"
printf -- '-%.0s' $(seq 1 118); echo

any=0
for dir in "$SPECS_DIR"/*/; do
  [ -d "$dir" ] || continue
  slug="$(basename "$dir")"
  [ "$slug" = "_template" ] && continue
  if [ -n "$FILTER" ] && [ "$slug" != "$FILTER" ]; then continue; fi
  any=1

  current="(nenhum artefato)"
  next="/btt-sdd:prd"
  pending=0
  revalidate="não"

  for stage in "${STAGES[@]}"; do
    file="${dir}${stage}.md"
    [ -f "$file" ] || continue

    if [ "$stage" = "prd" ] || [ "$stage" = "trd" ]; then
      if grep -qE '^[[:space:]]*-[[:space:]]*\[x\][[:space:]]*Aprovado por' "$file" 2>/dev/null; then
        current="$(label "$stage")"
        next="$(next_cmd "$stage")"
      else
        current="$(label "$stage") (rascunho, não aprovado)"
        next="(aprovar $(label "$stage") antes de continuar)"
      fi
    else
      verdict="$(grep -A2 -iE '##.*Veredito geral' "$file" 2>/dev/null \
        | grep -E '\*\*.+\*\*' | head -1 \
        | sed -E 's/.*\*\*(.+)\*\*.*/\1/')"
      case "$verdict" in
        *[Rr]eprovado*)
          current="$(label "$stage") — REPROVADO"
          next="/btt-sdd:implement (corrigir achados)"
          ;;
        *[Aa]provado*)
          extra=""
          case "$verdict" in *[Rr]essalvas*) extra=" (com ressalvas)";; esac
          current="$(label "$stage")${extra}"
          next="$(next_cmd "$stage")"
          ;;
        *)
          current="$(label "$stage") (veredito não identificado — leia o arquivo)"
          ;;
      esac
    fi

    if grep -qi 'requer revalida' "$file" 2>/dev/null; then
      revalidate="sim ($(label "$stage"))"
    fi

    p="$(grep -cE '\|[[:space:]]*pendente[[:space:]]*\|' "$file" 2>/dev/null)"
    pending=$((pending + ${p:-0}))
  done

  printf '%-32s | %-30s | %-26s | %-4s | %s\n' "$slug" "$current" "$next" "$pending" "$revalidate"
done

if [ "$any" = "0" ]; then
  if [ -n "$FILTER" ]; then
    echo "Nenhuma feature '$FILTER' encontrada em $SPECS_DIR/."
  else
    echo "Nenhuma feature encontrada em $SPECS_DIR/ (fora de _template)."
  fi
fi
