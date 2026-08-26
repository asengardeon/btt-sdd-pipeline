# Resumo do estagio de cada feature em specs/, sem precisar ler cada artefato
# inteiro no contexto do agente. Usado pela skill deste plugin (skills/status/,
# comando /btt-sdd:status) - equivalente a .claude/skills/sdd-status (/sdd-status).
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
  "prd"              = "/btt-sdd:trd"
  "trd"              = "/btt-sdd:implement"
  "code-review"      = "/btt-sdd:qa"
  "qa-report"        = "/btt-sdd:security"
  "security-review"  = "/btt-sdd:sre"
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
  $next = "/btt-sdd:prd"
  $pending = 0
  $revalidate = "nao"

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
      $verdict = ""
      if ($content -match '(?ms)##.*Veredito geral\s*?\r?\n+.*?\*\*(.+?)\*\*') {
        $verdict = $Matches[1]
      }
      if ($verdict -match '(?i)reprovado') {
        $current = "$($Labels[$stage]) - REPROVADO"
        $next = "/btt-sdd:implement (corrigir achados)"
      } elseif ($verdict -match '(?i)aprovado') {
        $extra = ""
        if ($verdict -match '(?i)ressalvas') { $extra = " (com ressalvas)" }
        $current = "$($Labels[$stage])$extra"
        $next = $NextCmds[$stage]
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

    $pending += [regex]::Matches($content, '\|\s*pendente\s*\|').Count
  }

  "{0,-32} | {1,-30} | {2,-26} | {3,-4} | {4}" -f $slugName, $current, $next, $pending, $revalidate
}
