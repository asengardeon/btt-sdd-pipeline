# Resumo do estagio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado por .claude/skills/sdd-status.
#
# Uso: powershell -File scripts/sdd-status.ps1 [-Slug <slug>] [-CheckDocs]
#   -Slug (opcional) - mostra so aquela feature.
#   -CheckDocs (opcional) - compara docs/*.md deste projeto contra o scaffold
#     da versao instalada do plugin, sinalizando divergencia.
#
# Saida: aproximacao best-effort via regex sobre a convencao de formatacao dos
# templates em specs/_template/. Se um artefato fugir muito do formato padrao
# (veredito sem **negrito**, checkbox fora do padrao), o agente que chamou
# este script deve cair de volta para ler o arquivo inteiro.
#
# Nota: strings deste arquivo evitam acentos de propósito - .ps1 sem BOM é
# lido pela codepage do sistema no Windows PowerShell 5.1, e caracteres
# multibyte podem quebrar o parser.

param([string]$Slug, [switch]$CheckDocs)

# Compara docs/*.md deste projeto contra o scaffold de /create-project (siblings
# de scripts/ sob skills/, tanto na junction quanto no pacote do plugin) - so
# sinaliza divergencia, nunca aplica merge automatico (issue #23: projetos
# criados antes de uma melhoria de processo no plugin nunca se beneficiam dela
# ate alguem perceber a divergencia manualmente).
function Get-DocsDrift {
  $ScaffoldDocs = Join-Path $PSScriptRoot "..\..\create-project\scaffold\docs"
  if (-not (Test-Path $ScaffoldDocs)) {
    Write-Host ""
    Write-Host "Checagem de docs desatualizados: scaffold nao encontrado em '$ScaffoldDocs' - pulando."
    return
  }
  $PluginJson = Join-Path $PSScriptRoot "..\..\..\.claude-plugin\plugin.json"
  $Version = "desconhecida"
  if (Test-Path $PluginJson) {
    $jsonContent = Get-Content $PluginJson -Raw
    if ($jsonContent -match '"version"\s*:\s*"([^"]+)"') {
      $Version = $Matches[1]
    }
  }

  Write-Host ""
  Write-Host "Checagem de docs desatualizados (docs/*.md deste projeto vs. scaffold da versao $Version):"
  $anyDiff = $false
  foreach ($f in (Get-ChildItem -Path $ScaffoldDocs -Filter "*.md")) {
    $projectFile = Join-Path "docs" $f.Name
    if (Test-Path $projectFile) {
      $a = Get-Content $projectFile -Raw
      $b = Get-Content $f.FullName -Raw
      if ($a -ne $b) {
        $anyDiff = $true
        Write-Host "  - docs/$($f.Name) diverge do scaffold da versao $Version - revise manualmente ou peca pra atualizar."
      }
    }
  }
  if (-not $anyDiff) {
    Write-Host "  Nenhuma divergencia encontrada."
  }
}

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
function Get-LatestVerdict {
  param([string]$Content)
  $inSec = $false
  $lastRow = $null
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '^#{1,4}\s.*Hist.rico de aprova') { $inSec = $true; continue }
    if ($inSec -and $line -match '^#{1,4}\s') { $inSec = $false }
    if ($inSec -and $line -match '^\|') { $lastRow = $line }
  }
  if ($lastRow -and $lastRow -notmatch '^\|[-|\s]+\|?$') {
    return $lastRow
  }
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
        for ($i = 0; $i -lt $cols.Count; $i++) { if ($cols[$i] -eq 'Status') { $statusIdx = $i } }
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
$Stages = @("prd", "trd", "code-review", "qa-report", "security-review", "sre-review")

$Labels = @{
  "prd"              = "PRD"
  "trd"              = "TRD"
  "code-review"      = "Code review"
  "qa-report"        = "QA"
  "security-review"  = "Seguranca"
  "sre-review"       = "SRE"
}
$NextCmds = @{
  "prd"              = "/sdd-trd"
  "trd"              = "/sdd-implement"
  "code-review"      = "/sdd-qa"
  "qa-report"        = "/sdd-security"
  "security-review"  = "/sdd-sre"
  "sre-review"       = "(pipeline concluido)"
}

if (-not (Test-Path $SpecsDir)) {
  Write-Host "Nenhum diretorio '$SpecsDir/' encontrado a partir do diretorio atual."
  if ($CheckDocs) { Get-DocsDrift }
  exit 0
}

"{0,-32} | {1,-30} | {2,-26} | {3,-4} | {4}" -f "Feature", "Etapa atual", "Proximo comando", "Pend", "Revalidar"
"-" * 118

$dirs = Get-ChildItem -Path $SpecsDir -Directory | Where-Object { $_.Name -ne "_template" }
if ($Slug) { $dirs = $dirs | Where-Object { $_.Name -eq $Slug } }

if (-not $dirs) {
  if ($Slug) { Write-Host "Nenhuma feature '$Slug' encontrada em $SpecsDir/." }
  else { Write-Host "Nenhuma feature encontrada em $SpecsDir/ (fora de _template)." }
  if ($CheckDocs) { Get-DocsDrift }
  exit 0
}

foreach ($d in $dirs) {
  $slugName = $d.Name
  $current = "(nenhum artefato)"
  $next = "/sdd-prd"
  $pending = 0
  $revalidate = "nao"
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
      } else {
        $current = "$($Labels[$stage]) (veredito nao identificado - leia o arquivo)"
      }
    }

    if ($content -match '(?i)requer revalida') {
      # Uma flag "requer revalidacao" registrada no log pode ja ter sido resolvida por
      # uma (re)aprovacao formal posterior do artefato-alvo (secao "Aprovacao" do PRD
      # ou do TRD - os unicos artefatos com checkbox "Aprovado por"). O alvo nem sempre
      # e o proprio arquivo: uma flag registrada no log do PRD tipicamente aponta para
      # "TRD requer revalidacao". Para cada linha de log com a flag, identifica o
      # artefato-alvo pela palavra TRD/PRD na propria linha e compara a data da flag
      # com a data da (re)aprovacao mais recente desse artefato-alvo.
      $flagLines = [regex]::Matches($content, '(?mi)^\|\s*(\d{4}-\d{2}-\d{2})\s*\|.*requer revalida.*$')
      $unresolved = $false

      foreach ($m in $flagLines) {
        $flagDate = $m.Groups[1].Value
        $lineText = $m.Value
        $targetFile = $null
        if ($lineText -match '(?i)\bTRD\b') {
          $targetFile = Join-Path $d.FullName "trd.md"
        } elseif ($lineText -match '(?i)\bPRD\b') {
          $targetFile = Join-Path $d.FullName "prd.md"
        }

        if (-not $targetFile -or -not (Test-Path $targetFile)) {
          $unresolved = $true
          continue
        }

        $targetContent = Get-Content $targetFile -Raw
        # @(...) força coleção mesmo com um único match — sem isso, um resultado só vira
        # string escalar e "[-1]" pega o último caractere da data, não a data inteira.
        $approveDates = @([regex]::Matches($targetContent, '(?i)(?:re)?aprovad[oa] por.*?em\s+(\d{4}-\d{2}-\d{2})') |
          ForEach-Object { $_.Groups[1].Value } | Sort-Object)
        $approveDate = if ($approveDates.Count -gt 0) { $approveDates[-1] } else { $null }

        if (-not $approveDate -or $flagDate -gt $approveDate) {
          $unresolved = $true
        }
      }

      if ($unresolved) {
        $revalidate = "sim ($($Labels[$stage]))"
      }
    }

    $pending += Get-ValidarDepoisPendentesCount $content
  }

  "{0,-32} | {1,-30} | {2,-26} | {3,-4} | {4}" -f $slugName, $current, $next, $pending, $revalidate
}

if ($CheckDocs) { Get-DocsDrift }
