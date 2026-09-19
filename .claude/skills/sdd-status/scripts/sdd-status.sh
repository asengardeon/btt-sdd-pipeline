#!/usr/bin/env bash
# Resumo do estágio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado por .claude/skills/sdd-status.
#
# Uso: scripts/sdd-status.sh [slug]
#   slug (opcional) — mostra só aquela feature.
#
# Saída: aproximação best-effort via grep/awk sobre a convenção de formatação
# dos templates em specs/_template/. Se um artefato fugir muito do formato
# padrão (veredito sem **negrito**, checkbox fora do padrão), o agente que
# chamou este script deve cair de volta para ler o arquivo inteiro.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECS_DIR="specs"
FILTER=""
for arg in "$@"; do
  FILTER="$arg"
done

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
# issue #144 corrigiu um falso-positivo sistemático em fatia única/última fatia:
# (a) a convenção real usada pelos agentes de revisão nem sempre escreve
# "concluído (mergeado)" — "aprovado (mergeado, PR #N)" e "implementado" também
# significam tarefa concluída; (b) uma linha removida/não aplicável (`—`, `n/a`,
# "removida", "descartada" na coluna Status) não é uma pendência real; (c) o caso
# mais comum na prática — "aprovado (SRE, PR #N)" — é ambíguo por texto sozinho:
# a mesma string descreve tanto "SRE aprovou, PR ainda não mergeado" (pendente de
# verdade) quanto "SRE aprovou e o PR já foi mergeado há dias, ninguém atualizou a
# coluna" (falso-positivo) — só distinguível cruzando com o estado real do PR no
# GitHub. Quando a coluna Status não bate com nenhum padrão "concluído" conhecido
# mas referencia um PR (`#N`), confirma via `gh pr view` antes de contar como
# pendente; sem `gh` disponível ou sem PR referenciado, cai no comportamento
# conservador anterior (conta como pendente) — nunca trava nem finge certeza.
_pr_merged() {
  command -v gh >/dev/null 2>&1 || { echo ""; return; }
  gh pr view "$1" --json state -q '.state' 2>/dev/null
}

has_fatia_pendente() {
  local trd_file="$1"
  [ -f "$trd_file" ] || { echo "0"; return; }
  local found=0 status lstatus stripped pr_num pr_state
  while IFS= read -r status; do
    [ -z "$status" ] && continue
    lstatus="$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"
    if printf '%s' "$lstatus" | grep -qE 'conclu.*do|aprovado.*mergead|^implementado$|n/a|removid|descartad'; then
      continue
    fi
    stripped="$(printf '%s' "$status" | tr -cd '[:alnum:]')"
    if [ -z "$stripped" ]; then
      # placeholder puro (—, -, --, etc.) — tarefa removida/não aplicável, não pendente.
      continue
    fi
    pr_num="$(printf '%s' "$status" | grep -oE '#[0-9]+' | head -1 | tr -d '#')"
    if [ -n "$pr_num" ]; then
      pr_state="$(_pr_merged "$pr_num")"
      [ "$pr_state" = "MERGED" ] && continue
    fi
    found=1
  done < <(awk -v trd="$trd_file" '
    BEGIN { insec = 0; status_idx = 0; header_seen = 0; hdr_n = 0 }
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
        hdr_n = n
        for (i = 1; i <= n; i++) { if (cols[i] == "Status") status_idx = i }
        next
      }
      if (n != hdr_n) {
        print "AVISO: linha da tabela de decomposição em " trd " tem " n " colunas, cabeçalho tem " hdr_n " — provável \"|\" literal/escapado dentro de uma célula deslocando colunas; linha ignorada em vez de reportar Status errado: " line > "/dev/stderr"
        next
      }
      if (status_idx > 0) print cols[status_idx]
    }
  ' "$trd_file")
  if [ "$found" = "1" ]; then echo 1; else echo 0; fi
}

STAGES=(prd trd code-review ux-review qa-report security-review sre-review)

label() {
  case "$1" in
    prd) echo "PRD" ;;
    trd) echo "TRD" ;;
    code-review) echo "Code review" ;;
    ux-review) echo "UX review" ;;
    qa-report) echo "QA" ;;
    security-review) echo "Segurança" ;;
    sre-review) echo "SRE" ;;
  esac
}

next_cmd() {
  case "$1" in
    prd) echo "/sdd-trd" ;;
    trd) echo "/sdd-implement" ;;
    code-review) echo "/sdd-ux-review" ;;
    ux-review) echo "/sdd-qa" ;;
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
    elif [ "$stage" = "qa-report" ] && grep -qiE '^#{1,4}[[:space:]]*Decis.*o:[[:space:]]*QA pulado' "$file" 2>/dev/null; then
      # QA formalmente pulado (justificado) — issue #163: sem essa checagem, um hotfix
      # puramente técnico sem critério de aceite de produto (skills/hotfix/SKILL.md, passo 5)
      # caía no fallback "veredito não identificado" do case abaixo, confundido com QA que
      # rodou sem deixar veredito claro. Estado terminal distinto, sem próximo comando —
      # reabrir QA é escolha explícita do usuário, não o fluxo padrão.
      current="QA pulado (justificado)"
      next="(nenhum — decisão registrada)"
    elif [ "$stage" = "ux-review" ] && grep -qiE '^#{1,4}[[:space:]]*Decis.*o:[[:space:]]*UX review pulado' "$file" 2>/dev/null; then
      # UX review formalmente pulada (justificada, .claude/skills/sdd-ux-review/SKILL.md,
      # passo 3) — fatia sem superfície de UI perceptível. Diferente de "QA pulado" acima,
      # não é um estado terminal: o pipeline segue normalmente para /sdd-qa.
      current="UX review pulada (não aplicável)"
      next="$(next_cmd "$stage")"
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

