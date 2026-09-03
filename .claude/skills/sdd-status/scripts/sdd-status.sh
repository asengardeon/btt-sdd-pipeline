#!/usr/bin/env bash
# Resumo do estágio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado por .claude/skills/sdd-status.
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

# Devolve o veredito da RODADA MAIS RECENTE de um artefato de revisão: prefere a
# última linha da tabela "Histórico de aprovações por fatia" (append-only por
# design — nunca sobrescrita, sempre reflete a fatia mais recente) e só cai para o
# texto em negrito da seção "Veredito geral" se não houver tabela preenchida
# (issue #37: pegar a 1ª ocorrência da palavra "reprovado" no arquivo inteiro
# reportava REPROVADO mesmo quando uma reverificação posterior já tinha aprovado).
# O nível de cabeçalho (#/##/###/####) varia entre artefatos reais gerados em
# versões diferentes do pipeline — o template usa "###", mas issue #44 confirmou
# artefatos reais com "##" e até "#" para o mesmo cabeçalho, o que fazia a detecção
# nunca disparar e cair sempre no fallback (reintroduzindo o bug da #37). Aceita
# 1 a 4 "#" em vez de exigir um nível fixo.
latest_verdict() {
  local file="$1"
  local hist_last
  hist_last="$(awk '
    /^#{1,4}[[:space:]].*Histórico de aprovações por fatia/ { insec = 1; next }
    insec && /^#{1,4}[[:space:]]/ { insec = 0 }
    insec && /^\|/ { line = $0 }
    END { print line }
  ' "$file" 2>/dev/null)"
  if [ -n "$hist_last" ] && ! echo "$hist_last" | grep -qE '^\|[-|[:space:]]+\|?$'; then
    echo "$hist_last"
    return
  fi
  grep -A2 -iE '#{1,4}.*Veredito geral' "$file" 2>/dev/null \
    | grep -E '\*\*.+\*\*' | tail -1 \
    | sed -E 's/.*\*\*(.+)\*\*.*/\1/'
}

# Conta só pendências reais de "## ... VALIDAR DEPOIS" (mesmo escopo de
# sdd-pending.sh) — issue #38: contar qualquer ocorrência da palavra "pendente" no
# arquivo inteiro também pegava linhas da tabela "Decomposição de tarefas e
# dependências" do TRD (Status=pendente de uma fatia futura ainda não implementada),
# inflando a contagem de VALIDAR DEPOIS com algo que não é uma pendência de validação.
count_validar_depois_pendentes() {
  awk '
    BEGIN { insec = 0; count = 0 }
    /^## .*VALIDAR DEPOIS/ { insec = 1; next }
    /^## / && insec == 1 { insec = 0 }
    insec == 1 && /^\|/ {
      line = $0
      gsub(/^\| */, "", line); gsub(/ *\|$/, "", line)
      n = split(line, cols, "|")
      for (i = 1; i <= n; i++) { gsub(/^ +| +$/, "", cols[i]) }
      if (n >= 4 && cols[1] != "ID" && cols[1] !~ /^-+$/ && cols[4] ~ /pendente/) count++
    }
    END { print count }
  ' "$1" 2>/dev/null
}

# Verifica se a tabela "Decomposição de tarefas e dependências" do TRD tem alguma
# tarefa cujo Status ainda não é "concluído (mergeado)" — issue #38: SRE aprovado
# não significa "pipeline concluído" se existe uma fatia 2+ com tarefas ainda não
# implementadas; o script reportava "(pipeline concluído)" só com base no veredito
# de SRE, sem cruzar com a decomposição de tarefas do TRD.
# issue #44 corrigiu dois problemas adicionais aqui: (a) aceita 1 a 4 "#" no
# cabeçalho da seção, mesma razão de latest_verdict() acima; (b) `conclu[ií]do`
# é uma expressão multibyte que não casa em locale C/POSIX (LANG/LC_ALL vazios) —
# trocado por `conclu.*do`, que não depende de reconhecer o byte do acento; (c)
# isola o valor da coluna Status pelo cabeçalho (mesma técnica de
# count_validar_depois_pendentes() acima) em vez de checar a linha inteira, para
# não confundir texto livre de outra coluna mencionando "concluído" com o status
# real da tarefa.
has_fatia_pendente() {
  local trd_file="$1"
  [ -f "$trd_file" ] || { echo "0"; return; }
  awk '
    BEGIN { insec = 0; found = 0; status_idx = 0; header_seen = 0 }
    /^#{1,4}[[:space:]].*Decomposição de tarefas/ { insec = 1; next }
    insec == 1 && /^#{1,4}[[:space:]]/ { insec = 0 }
    insec == 1 && /^\|/ {
      if ($0 ~ /^\|[-|[:space:]]+\|?$/) next
      line = $0
      gsub(/^\| */, "", line); gsub(/ *\|$/, "", line)
      n = split(line, cols, "|")
      for (i = 1; i <= n; i++) { gsub(/^ +| +$/, "", cols[i]) }
      if (!header_seen) {
        header_seen = 1
        for (i = 1; i <= n; i++) { if (cols[i] == "Status") status_idx = i }
        next
      }
      if (status_idx > 0 && tolower(cols[status_idx]) !~ /conclu.*do/) { found = 1 }
    }
    END { print (found ? 1 : 0) }
  ' "$trd_file" 2>/dev/null
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
    prd) echo "/sdd-trd" ;;
    trd) echo "/sdd-implement" ;;
    code-review) echo "/sdd-qa" ;;
    qa-report) echo "/sdd-security" ;;
    security-review) echo "/sdd-sre" ;;
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
  next="/sdd-prd"
  pending=0
  revalidate="não"
  fatia_pendente="$(has_fatia_pendente "${dir}trd.md")"

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
      verdict="$(latest_verdict "$file")"
      case "$verdict" in
        *[Rr]eprovado*)
          current="$(label "$stage") — REPROVADO"
          next="/sdd-implement (corrigir achados)"
          ;;
        *[Aa]provado*)
          extra=""
          case "$verdict" in *[Rr]essalvas*) extra=" (com ressalvas)";; esac
          current="$(label "$stage")${extra}"
          if [ "$stage" = "sre-review" ] && [ "$fatia_pendente" = "1" ]; then
            next="/sdd-implement (retomar próxima fatia)"
          else
            next="$(next_cmd "$stage")"
          fi
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

    p="$(count_validar_depois_pendentes "$file")"
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
