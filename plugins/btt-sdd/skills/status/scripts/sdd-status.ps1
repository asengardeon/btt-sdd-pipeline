# Resumo do estagio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado por .claude/skills/sdd-status.
#
# Uso: powershell -File scripts/sdd-status.ps1 [-Slug <slug>]
#   -Slug (opcional) - mostra so aquela feature.
#
# Saida: aproximacao best-effort via regex sobre a convencao de formatacao dos
# templates em specs/_template/. Se um artefato fugir muito do formato padrao
# (veredito sem **negrito**, checkbox fora do padrao), o agente que chamou
# este script deve cair de volta para ler o arquivo inteiro.
#
# Nota: strings deste arquivo evitam acentos de propósito - .ps1 sem BOM é
# lido pela codepage do sistema no Windows PowerShell 5.1, e caracteres
# multibyte podem quebrar o parser.

param([string]$Slug)

# Devolve o veredito da RODADA MAIS RECENTE de um artefato de revisao: prefere a
# ultima linha da tabela "Historico de aprovacoes por fatia" (append-only por
# design - nunca sobrescrita, sempre reflete a fatia mais recente) e so cai para o
# texto em negrito da secao "Veredito geral" se nao houver tabela preenchida
# (issue #37: pegar a 1a ocorrencia da palavra "reprovado" no arquivo inteiro
# reportava REPROVADO mesmo quando uma reverificacao posterior ja tinha aprovado).
# O nivel de cabecalho (#/##/###/####) varia entre artefatos reais gerados em
# versoes diferentes do pipeline - o template usa "###", mas issue #44 confirmou
# artefatos reais com "##" e ate "#" para o mesmo cabecalho, o que fazia a deteccao
# nunca disparar e cair sempre no fallback (reintroduzindo o bug da #37). Aceita
# 1 a 4 "#" em vez de exigir um nivel fixo.
# A ultima linha do historico nao e o ultimo veredito (issue #333): um hotfix que pula
# formalmente uma etapa acrescenta "| ... | Pulado (justificado) | ... |", e essa linha
# ficava sendo lida como veredito ilegivel - /sdd-status mandava rodar de novo uma etapa
# concluida. Sobe a tabela ate a linha mais recente que CARREGUE veredito; se nenhuma
# carregar, devolve a mais recente mesmo assim, para o bloco de classificacao tratar
# "Pulado (justificado)" como estado proprio em vez de erro de parsing.
function Get-LatestVerdict {
  param([string]$Content)
  $inSec = $false
  $lastRow = $null
  $rowWithVerdict = $null
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '^#{1,4}\s.*Hist.rico de aprova') { $inSec = $true; continue }
    if ($inSec -and $line -match '^#{1,4}\s') { $inSec = $false }
    if ($inSec -and $line -match '^\|') {
      if ($line -match '^\|[-|\s]+\|?$') { continue }
      $lastRow = $line
      if ($line -match '(?i)aprovado|reprovado') { $rowWithVerdict = $line }
    }
  }
  if ($rowWithVerdict) { return $rowWithVerdict }
  if ($lastRow) { return $lastRow }
  $verdictMatches = [regex]::Matches($Content, '(?ms)#{1,4}.*Veredito geral\s*?\r?\n+.*?\*\*(.+?)\*\*')
  if ($verdictMatches.Count -gt 0) {
    return $verdictMatches[$verdictMatches.Count - 1].Groups[1].Value
  }
  return ""
}

# Conta so pendencias reais de "## ... VALIDAR DEPOIS" (mesmo escopo de
# sdd-pending.ps1) - issue #38: contar qualquer ocorrencia da palavra "pendente" no
# arquivo inteiro tambem pegava linhas da tabela "Decomposicao de tarefas e
# dependencias" do TRD (Status=pendente de uma fatia futura ainda nao implementada),
# inflando a contagem de VALIDAR DEPOIS com algo que nao e uma pendencia de validacao.
function Get-ValidarDepoisPendentesCount {
  param([string]$Content)
  $inSec = $false
  $count = 0
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '^## .*VALIDAR DEPOIS') { $inSec = $true; continue }
    if ($inSec -and $line -match '^## ') { $inSec = $false }
    if ($inSec -and $line -match '^\|') {
      $trimmed = $line.Trim().Trim('|')
      $cols = $trimmed -split '\|' | ForEach-Object { $_.Trim() }
      if ($cols.Count -ge 4 -and $cols[0] -ne 'ID' -and $cols[0] -notmatch '^-+$' -and $cols[3] -match 'pendente') {
        $count++
      }
    }
  }
  return $count
}

# Verifica se a tabela "Decomposicao de tarefas e dependencias" do TRD tem alguma
# tarefa cujo Status ainda nao e "concluido (mergeado)" - issue #38: SRE aprovado
# nao significa "pipeline concluido" se existe uma fatia 2+ com tarefas ainda nao
# implementadas; o script reportava "(pipeline concluido)" so com base no veredito
# de SRE, sem cruzar com a decomposicao de tarefas do TRD. So considera o sinal
# quando a tabela realmente tem uma coluna Status (TRDs de formato antigo, sem essa
# coluna, nao geram falso positivo). issue #44 corrigiu dois problemas adicionais:
# (a) aceita 1 a 4 "#" no cabecalho da secao, mesma razao de Get-LatestVerdict
# acima; (b) isola o valor da coluna Status pelo cabecalho (mesma tecnica de
# Get-ValidarDepoisPendentesCount acima) em vez de checar a linha inteira, para
# nao confundir texto livre de outra coluna mencionando "concluido" com o status
# real da tarefa.
# issue #144 corrigiu um falso-positivo sistematico em fatia unica/ultima fatia:
# (a) a convencao real usada pelos agentes de revisao nem sempre escreve
# "concluido (mergeado)" - "aprovado (mergeado, PR #N)" e "implementado" tambem
# significam tarefa concluida; (b) uma linha removida/nao aplicavel (-, n/a,
# "removida", "descartada" na coluna Status) nao e uma pendencia real; (c) o caso
# mais comum na pratica - "aprovado (SRE, PR #N)" - e ambiguo por texto sozinho:
# a mesma string descreve tanto "SRE aprovou, PR ainda nao mergeado" (pendente de
# verdade) quanto "SRE aprovou e o PR ja foi mergeado ha dias, ninguem atualizou a
# coluna" (falso-positivo) - so distinguivel cruzando com o estado real do PR no
# GitHub. Quando a coluna Status nao bate com nenhum padrao "concluido" conhecido
# mas referencia um PR (#N), confirma via "gh pr view" antes de contar como
# pendente; sem gh disponivel ou sem PR referenciado, cai no comportamento
# conservador anterior (conta como pendente) - nunca trava nem finge certeza.
function Get-PrMergedState {
  param([string]$PrNumber)
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { return "" }
  try {
    $state = gh pr view $PrNumber --json state -q '.state' 2>$null
    if ($LASTEXITCODE -ne 0) { return "" }
    return $state
  } catch {
    return ""
  }
}

function Test-FatiaPendente {
  param([string]$TrdPath)
  if (-not (Test-Path $TrdPath)) { return $false }
  $content = Get-Content $TrdPath -Raw
  $inSec = $false
  $headerSeen = $false
  $statusIdx = -1
  $headerColCount = 0
  $found = $false
  foreach ($line in ($content -split "`r?`n")) {
    if ($line -match '^#{1,4}\s.*Decomposi.{3} de tarefas') { $inSec = $true; continue }
    if ($inSec -and $line -match '^#{1,4}\s') { $inSec = $false }
    if ($inSec -and $line -match '^\|') {
      if ($line -match '^\|[-|\s]+\|?$') { continue }
      $trimmed = $line.Trim().Trim('|')
      $cols = $trimmed -split '\|' | ForEach-Object { $_.Trim() }
      if (-not $headerSeen) {
        $headerSeen = $true
        $headerColCount = $cols.Count
        for ($i = 0; $i -lt $cols.Count; $i++) { if ($cols[$i] -eq 'Status') { $statusIdx = $i } }
        continue
      }
      if ($cols.Count -ne $headerColCount) {
        Write-Warning "Linha da tabela de decomposicao em $TrdPath tem $($cols.Count) colunas, cabecalho tem $headerColCount - provavel '|' literal/escapado dentro de uma celula deslocando colunas; linha ignorada em vez de reportar Status errado: $line"
        continue
      }
      if ($statusIdx -ge 0 -and $statusIdx -lt $cols.Count) {
        $status = $cols[$statusIdx]
        if ($status -match '(?i)conclu.do|aprovado.*mergead|^implementado$|n/a|removid|descartad') {
          continue
        }
        $stripped = ($status -replace '[^a-zA-Z0-9]', '')
        if ([string]::IsNullOrEmpty($stripped)) {
          # placeholder puro (-, --, etc.) - tarefa removida/nao aplicavel, nao pendente.
          continue
        }
        $prMatch = [regex]::Match($status, '#(\d+)')
        if ($prMatch.Success) {
          $prState = Get-PrMergedState -PrNumber $prMatch.Groups[1].Value
          if ($prState -eq 'MERGED') { continue }
        }
        $found = $true
      }
    }
  }
  return $found
}

$SpecsDir = "specs"
$Stages = @("prd", "trd", "code-review", "ux-review", "qa-report", "security-review", "sre-review")

$Labels = @{
  "prd"              = "PRD"
  "trd"              = "TRD"
  "code-review"      = "Code review"
  "ux-review"        = "UX review"
  "qa-report"        = "QA"
  "security-review"  = "Seguranca"
  "sre-review"       = "SRE"
}
# Artefatos citados IMEDIATAMENTE antes de "requer revalidacao" (issue #332). Identificar o
# alvo com \bTRD\b na linha inteira errava de duas formas: pegava o TRD quando ele era so a
# *causa* ("**Seguranca requer revalidacao.** TRD revisao 9 redesenhou ..."), e casava a
# sentenca NEGADA que o proprio trd.template.md induz ("Nenhuma - nenhuma etapa a jusante
# **requer revalidacao**"). Exigir o nome colado na frase resolve os dois: em "a jusante
# requer revalidacao" nao ha artefato antes, entao nao e flag.
# Devolve TODOS os alvos da linha - uma entrada de log pode sinalizar mais de uma etapa, e
# parar no primeiro esconderia as demais.
function Get-RevalidationTargets {
  param([string]$Line)
  $sufixo = '\*{0,2}\s+requer\s+revalida'
  $mapa = [ordered]@{
    'prd'             = "PRD$sufixo"
    'trd'             = "TRD$sufixo"
    'code-review'     = "(code review|revis.o de c.digo)$sufixo"
    'ux-review'       = "(ux review|revis.o de ux)$sufixo"
    'qa-report'       = "QA$sufixo"
    'security-review' = "seguran.a$sufixo"
    'sre-review'      = "SRE$sufixo"
  }
  foreach ($k in $mapa.Keys) {
    if ($Line -match "(?i)$($mapa[$k])") { $k }
  }
}

# Agente que assina a revalidacao de cada etapa. code-review/ux-review/qa-report/
# security-review/sre-review nao tem checkbox "Aprovado por" - era por isso que, antes da
# #332, essas cinco etapas nao tinham NENHUM caminho de resolucao e a flag ficava eterna.
$StageAgents = @{
  'code-review'     = 'code-reviewer'
  'ux-review'       = 'ux-designer'
  'qa-report'       = 'qa-engineer'
  'security-review' = 'security-engineer'
  'sre-review'      = 'sre'
}

# $true se o log do artefato tem linha com data ESTRITAMENTE maior que a da flag, assinada
# pelo agente da etapa, e que nao seja ela propria outra flag. Estrito de proposito: a data
# tem granularidade de dia, entao uma entrada do mesmo dia pode ser anterior a flag - e
# resolver uma flag por engano e silencioso, enquanto deixa-la aberta e visivel.
function Test-RevalidatedInLog {
  param([string]$Content, [string]$FlagDate, [string]$Agent)
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '(?i)requer revalida') { continue }
    # captura explicita em vez de depender de $Matches sobreviver ao -match seguinte
    $mData = [regex]::Match($line, '^\|\s*(\d{4}-\d{2}-\d{2})')
    if (-not $mData.Success) { continue }
    $cols = $line -split '\|'
    if ($cols.Count -lt 3) { continue }
    $autor = $cols[2].Trim().ToLower()
    if ($mData.Groups[1].Value -gt $FlagDate -and $autor.Contains($Agent)) { return $true }
  }
  return $false
}

$NextCmds = @{
  "prd"              = "/sdd-trd"
  "trd"              = "/sdd-implement"
  "code-review"      = "/sdd-ux-review"
  "ux-review"        = "/sdd-qa"
  "qa-report"        = "/sdd-security"
  "security-review"  = "/sdd-sre"
  "sre-review"       = "(pipeline concluido)"
}

if (-not (Test-Path $SpecsDir)) {
  Write-Host "Nenhum diretorio '$SpecsDir/' encontrado a partir do diretorio atual."
  exit 0
}

"{0,-32} | {1,-30} | {2,-26} | {3,-4} | {4}" -f "Feature", "Etapa atual", "Proximo comando", "Pend", "Revalidar"
"-" * 118

$dirs = Get-ChildItem -Path $SpecsDir -Directory | Where-Object { $_.Name -ne "_template" }
if ($Slug) { $dirs = $dirs | Where-Object { $_.Name -eq $Slug } }

if (-not $dirs) {
  if ($Slug) { Write-Host "Nenhuma feature '$Slug' encontrada em $SpecsDir/." }
  else { Write-Host "Nenhuma feature encontrada em $SpecsDir/ (fora de _template)." }
  exit 0
}

foreach ($d in $dirs) {
  $slugName = $d.Name
  $current = "(nenhum artefato)"
  $next = "/sdd-prd"
  $pending = 0
  $revalidate = "nao"
  # acumula os alvos em vez de sobrescrever (issue #332): a coluna guardava uma string so e a
  # ultima etapa iterada vencia, entao uma flag legitima de outra etapa sumia da saida
  $revalAlvos = [ordered]@{}
  $fatiaPendente = Test-FatiaPendente (Join-Path $d.FullName "trd.md")

  foreach ($stage in $Stages) {
    $file = Join-Path $d.FullName "$stage.md"
    if (-not (Test-Path $file)) { continue }
    $content = Get-Content $file -Raw

    if ($stage -eq "prd" -or $stage -eq "trd") {
      if ($content -match '(?m)^\s*-\s*\[x\]\s*Aprovado por') {
        $current = $Labels[$stage]
        $next = $NextCmds[$stage]
      } else {
        $current = "$($Labels[$stage]) (rascunho, nao aprovado)"
        $next = "(aprovar $($Labels[$stage]) antes de continuar)"
      }
    } elseif ($stage -eq "qa-report" -and $content -match '(?mi)^#{1,4}\s*Decis.o:\s*QA pulado') {
      # QA formalmente pulado (justificado) - issue #163: sem essa checagem, um hotfix
      # puramente tecnico sem criterio de aceite de produto (skills/hotfix/SKILL.md, passo 5)
      # caia no fallback "veredito nao identificado" abaixo, confundido com QA que rodou sem
      # deixar veredito claro. Estado terminal distinto, sem proximo comando - reabrir QA e
      # escolha explicita do usuario, nao o fluxo padrao.
      $current = "QA pulado (justificado)"
      $next = "(nenhum - decisao registrada)"
    } elseif ($stage -eq "ux-review" -and $content -match '(?mi)^#{1,4}\s*Decis.o:\s*UX review pulado') {
      # UX review formalmente pulada (justificada, .claude/skills/sdd-ux-review/SKILL.md,
      # passo 3) - fatia sem superficie de UI perceptivel. Diferente de "QA pulado" acima,
      # nao e um estado terminal: o pipeline segue normalmente para /sdd-qa.
      $current = "UX review pulada (nao aplicavel)"
      $next = $NextCmds[$stage]
    } else {
      $verdict = Get-LatestVerdict $content
      if ($verdict -match '(?i)reprovado') {
        $current = "$($Labels[$stage]) - REPROVADO"
        $next = "/sdd-implement (corrigir achados)"
      } elseif ($verdict -match '(?i)aprovado') {
        $extra = ""
        if ($verdict -match '(?i)ressalvas') { $extra = " (com ressalvas)" }
        $current = "$($Labels[$stage])$extra"
        if ($stage -eq "sre-review" -and $fatiaPendente) {
          $next = "/sdd-implement (retomar proxima fatia)"
        } else {
          $next = $NextCmds[$stage]
        }
      } elseif ($verdict -match '(?i)pulado') {
        # Etapa formalmente pulada como unica entrada do historico (issue #333) - um
        # hotfix sem impacto de infra/CI pula SRE/seguranca por decisao registrada
        # (skills/hotfix/SKILL.md), e a linha do historico E o registro dela. Mesmo
        # tratamento que "QA pulado" acima: estado proprio, sem proximo comando.
        # Vem DEPOIS de aprovado/reprovado de proposito: uma linha pode dizer
        # "Aprovado ... UX pulado", e ai o veredito que vale e o "Aprovado".
        $current = "$($Labels[$stage]): etapa pulada (justificada)"
        $next = "(nenhum - decisao registrada)"
      } else {
        $current = "$($Labels[$stage]) (veredito nao identificado - leia o arquivo)"
      }
    }

    if ($content -match '(?i)requer revalida') {
      # Uma flag "requer revalidacao" registrada no log pode ja ter sido resolvida de duas
      # formas: (a) uma (re)aprovacao formal posterior do artefato-alvo - so PRD e TRD tem o
      # checkbox "Aprovado por"; (b) uma linha de log posterior no proprio artefato-alvo
      # assinada pelo agente daquela etapa, que e como uma revisao registra que refez o
      # trabalho. Antes da #332 so (a) existia, entao as cinco etapas de revisao nao tinham
      # caminho de resolucao nenhum e a flag ficava para sempre.
      $flagLines = [regex]::Matches($content, '(?mi)^\|\s*(\d{4}-\d{2}-\d{2})\s*\|.*requer revalida.*$')

      foreach ($m in $flagLines) {
        $flagDate = $m.Groups[1].Value
        # sem artefato colado na frase nao sai alvo nenhum: e mencao, ou a negacao que o
        # template induz ("nenhuma etapa a jusante requer revalidacao")
        foreach ($targetStage in (Get-RevalidationTargets $m.Value)) {
          $targetFile = Join-Path $d.FullName "$targetStage.md"
          if (-not (Test-Path $targetFile)) {
            $revalAlvos[$targetStage] = $true
            continue
          }

          $targetContent = Get-Content $targetFile -Raw
          # @(...) força coleção mesmo com um único match — sem isso, um resultado só vira
          # string escalar e "[-1]" pega o último caractere da data, não a data inteira.
          $approveDates = @([regex]::Matches($targetContent, '(?i)(?:re)?aprovad[oa] por.*?em\s+(\d{4}-\d{2}-\d{2})') |
            ForEach-Object { $_.Groups[1].Value } | Sort-Object)
          $approveDate = if ($approveDates.Count -gt 0) { $approveDates[-1] } else { $null }
          if ($approveDate -and $flagDate -le $approveDate) { continue }

          $agent = $StageAgents[$targetStage]
          if ($agent -and (Test-RevalidatedInLog $targetContent $flagDate $agent)) { continue }

          $revalAlvos[$targetStage] = $true
        }
      }
    }

    $pending += Get-ValidarDepoisPendentesCount $content
  }

  if ($revalAlvos.Count -gt 0) {
    $rotulos = ($revalAlvos.Keys | ForEach-Object { $Labels[$_] }) -join ", "
    $revalidate = "sim ($rotulos)"
  }

  "{0,-32} | {1,-30} | {2,-26} | {3,-4} | {4}" -f $slugName, $current, $next, $pending, $revalidate
}

