#!/usr/bin/env bash
# Resumo do estágio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado pela skill deste plugin (skills/status/,
# comando /btt-sdd:status) — equivalente a .claude/skills/sdd-status (/sdd-status).
#
# Uso: scripts/sdd-status.sh [slug] [--check-docs]
#   slug (opcional) — mostra só aquela feature.
#   --check-docs (opcional) — compara docs/*.md deste projeto contra o
#     scaffold da versão instalada do plugin, sinalizando divergência.
#
# Saída: aproximação best-effort via grep/awk sobre a convenção de formatação
# dos templates em specs/_template/. Se um artefato fugir muito do formato
# padrão (veredito sem **negrito**, checkbox fora do padrão), o agente que
# chamou este script deve cair de volta para ler o arquivo inteiro.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECS_DIR="specs"
FILTER=""
CHECK_DOCS=0
for arg in "$@"; do
  case "$arg" in
    --check-docs) CHECK_DOCS=1 ;;
    *) FILTER="$arg" ;;
  esac
done

# Compara docs/*.md deste projeto contra o scaffold de /create-project (siblings
# de scripts/ sob skills/, tanto na junction quanto no pacote do plugin) — só
# sinaliza divergência, nunca aplica merge automático (issue #23: projetos
# criados antes de uma melhoria de processo no plugin nunca se beneficiam dela
# até alguém perceber a divergência manualmente).
check_docs_drift() {
  local scaffold_docs="${SCRIPT_DIR}/../../create-project/scaffold/docs"
  if [ ! -d "$scaffold_docs" ]; then
    echo
    echo "Checagem de docs desatualizados: scaffold não encontrado em '$scaffold_docs' — pulando."
    return
  fi
  local plugin_json="${SCRIPT_DIR}/../../../.claude-plugin/plugin.json"
  local version="desconhecida"
  if [ -f "$plugin_json" ]; then
    version="$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$plugin_json" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
    [ -z "$version" ] && version="desconhecida"
  fi

  echo
  echo "Checagem de docs desatualizados (docs/*.md deste projeto vs. scaffold da versão $version):"
  local any_diff=0
  for f in "$scaffold_docs"/*.md; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    project_file="docs/${name}"
    if [ -f "$project_file" ] && ! cmp -s "$project_file" "$f"; then
      any_diff=1
      echo "  - docs/${name} diverge do scaffold da versão ${version} — revise manualmente ou peça pra atualizar."
    fi
  done
  if [ "$any_diff" = "0" ]; then
    echo "  Nenhuma divergência encontrada."
  fi
}

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
      # Uma flag "requer revalidação" registrada no log pode já ter sido resolvida por
      # uma (re)aprovação formal posterior do artefato-alvo (seção "Aprovação" do PRD
      # ou do TRD — os únicos artefatos com checkbox "Aprovado por"). O alvo nem sempre
      # é o próprio arquivo: uma flag registrada no log do PRD tipicamente aponta para
      # "TRD requer revalidação". Para cada linha de log com a flag, identifica o
      # artefato-alvo pela palavra TRD/PRD na própria linha e compara a data da flag
      # com a data da (re)aprovação mais recente desse artefato-alvo.
      unresolved=0
      while IFS= read -r flagline; do
        flag_date="$(echo "$flagline" | grep -oE '^\|[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')"
        target_file=""
        if [ -n "$flag_date" ]; then
          if echo "$flagline" | grep -qiw 'TRD'; then
            target_file="${dir}trd.md"
          elif echo "$flagline" | grep -qiw 'PRD'; then
            target_file="${dir}prd.md"
          fi
        fi
        if [ -z "$flag_date" ] || [ -z "$target_file" ] || [ ! -f "$target_file" ]; then
          unresolved=1
          continue
        fi
        approve_date="$(grep -ioE '(re)?aprovad[oa] por.*em[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}' "$target_file" 2>/dev/null \
          | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | tail -1)"
        if [ -z "$approve_date" ] || [[ "$flag_date" > "$approve_date" ]]; then
          unresolved=1
        fi
      done < <(grep -iE '^\|[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|.*requer revalida' "$file" 2>/dev/null)

      [ "$unresolved" = "1" ] && revalidate="sim ($(label "$stage"))"
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

if [ "$CHECK_DOCS" = "1" ]; then
  check_docs_drift
fi
