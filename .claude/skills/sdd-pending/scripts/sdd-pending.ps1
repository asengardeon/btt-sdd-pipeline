# Lista os itens "VALIDAR DEPOIS" com status "pendente" em todas as features
# de specs/ e em docs/BASELINE.md, sem precisar ler cada artefato inteiro no
# contexto do agente. Usado por .claude/skills/sdd-pending.
#
# Uso: powershell -File scripts/sdd-pending.ps1 [-Slug <slug>]
#   -Slug (opcional) - mostra so aquela feature.
#
# Nota: strings deste arquivo evitam acentos de proposito - .ps1 sem BOM e
# lido pela codepage do sistema no Windows PowerShell 5.1, e caracteres
# multibyte podem quebrar o parser ou sair como mojibake na saida.

param([string]$Slug)

$SpecsDir = "specs"
$Files = @("prd.md", "trd.md", "code-review.md", "qa-report.md", "security-review.md", "sre-review.md")
$ReferentialPattern = 'ver rodada|ver acima|mesma pend|repetid|sem novidade|inalterad|ja citad'

function Get-PendingRows {
  param([string]$Content)
  $rows = @()
  $inSection = $false
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '^## .*VALIDAR DEPOIS') { $inSection = $true; continue }
    if ($inSection -and $line -match '^## ') { $inSection = $false }
    if ($inSection -and $line -match '^\|') {
      $trimmed = $line.Trim().Trim('|')
      $cols = $trimmed -split '\|' | ForEach-Object { $_.Trim() }
      if ($cols.Count -ge 4 -and $cols[0] -ne 'ID' -and $cols[0] -notmatch '^-+$' -and $cols[3] -match 'pendente') {
        $rows += [PSCustomObject]@{ Id = $cols[0]; Pergunta = $cols[1]; Contexto = $cols[2] }
      }
    }
  }
  return $rows
}

# Colapsa linhas que so remetem a uma rodada anterior sem conteudo novo -
# mantem so a ocorrencia mais informativa por (feature, pergunta), na ordem
# de primeira aparicao de cada chave.
function Get-DedupedRows {
  param([array]$AllRows)
  $order = @()
  $kept = @{}
  foreach ($r in $AllRows) {
    $key = "$($r.Feature)|$($r.Pergunta)"
    if (-not $kept.ContainsKey($key)) {
      $kept[$key] = $r
      $order += $key
    } else {
      $curRef = $kept[$key].Contexto -match $ReferentialPattern
      $newRef = $r.Contexto -match $ReferentialPattern
      if ($curRef -and -not $newRef) {
        $kept[$key] = $r
      }
    }
  }
  return $order | ForEach-Object { $kept[$_] }
}

$allRows = @()

if (Test-Path "docs/BASELINE.md") {
  $content = Get-Content "docs/BASELINE.md" -Raw
  foreach ($row in (Get-PendingRows -Content $content)) {
    $allRows += [PSCustomObject]@{ Feature = "(baseline)"; Artefato = "BASELINE"; Id = $row.Id; Pergunta = $row.Pergunta; Contexto = $row.Contexto }
  }
}

if (Test-Path $SpecsDir) {
  $dirs = Get-ChildItem -Path $SpecsDir -Directory | Where-Object { $_.Name -ne "_template" }
  if ($Slug) { $dirs = $dirs | Where-Object { $_.Name -eq $Slug } }

  foreach ($d in $dirs) {
    foreach ($f in $Files) {
      $file = Join-Path $d.FullName $f
      if (-not (Test-Path $file)) { continue }
      $content = Get-Content $file -Raw
      foreach ($row in (Get-PendingRows -Content $content)) {
        $allRows += [PSCustomObject]@{ Feature = $d.Name; Artefato = $f; Id = $row.Id; Pergunta = $row.Pergunta; Contexto = $row.Contexto }
      }
    }
  }
}

"{0,-28} | {1,-16} | {2,-6} | {3,-42} | {4}" -f "Feature", "Artefato", "ID", "Pergunta", "Contexto"
"-" * 130

$deduped = Get-DedupedRows -AllRows $allRows
$found = $false
foreach ($row in $deduped) {
  $found = $true
  "{0,-28} | {1,-16} | {2,-6} | {3,-42} | {4}" -f $row.Feature, $row.Artefato, $row.Id, $row.Pergunta, $row.Contexto
}

if (-not $found) {
  Write-Host "Nenhuma pendencia VALIDAR DEPOIS em aberto."
}
