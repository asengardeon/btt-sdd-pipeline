# Lista os itens "VALIDAR DEPOIS" com status "pendente" e as tarefas ainda nao
# implementadas (tabela "Decomposicao de tarefas e dependencias" do TRD) em
# todas as features de specs/ e em docs/BASELINE.md, sem precisar ler cada
# artefato inteiro no contexto do agente. Usado pela skill deste plugin
# (skills/pending/, comando /btt-sdd:pending) - equivalente a
# .claude/skills/sdd-pending (/sdd-pending).
#
# Uso: powershell -File scripts/sdd-pending.ps1 [-Slug <slug>]
#   -Slug (opcional) - mostra so aquela feature.
#
# Nota: strings deste arquivo evitam acentos de proposito - .ps1 sem BOM e
# lido pela codepage do sistema no Windows PowerShell 5.1, e caracteres
# multibyte podem quebrar o parser ou sair como mojibake na saida.

param([string]$Slug)

$SpecsDir = "specs"
$Files = @("prd.md", "trd.md", "code-review.md", "ux-review.md", "qa-report.md", "security-review.md", "sre-review.md")
$ReferentialPattern = 'ver rodada|ver acima|mesma pend|repetid|sem novidade|inalterad|ja citad'
$OpenTaskStatusPattern = '^(pendente|em andamento|bloqueado)'

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
      $status4 = $cols[3] -replace '^\*+', ''
      if ($cols.Count -ge 4 -and $cols[0] -ne 'ID' -and $cols[0] -notmatch '^-+$' -and $status4 -match '^pendente') {
        $rows += [PSCustomObject]@{ Id = $cols[0]; Pergunta = $cols[1]; Contexto = $cols[2] }
      }
    }
  }
  return $rows
}

# Extrai da tabela "Decomposicao de tarefas e dependencias" do TRD as linhas
# cujo Status ainda nao chegou a "implementado" (pendente/em andamento/
# bloqueado). As colunas "Status"/"Issue GitHub" sao resolvidas pelo texto do
# cabecalho, nao por posicao fixa - a ordem das demais colunas ja variou entre
# TRDs reais, e um indice fixo ja fez esta funcao nunca encontrar nenhuma
# tarefa pendente de verdade (issue #189). ID/Tarefa/Trilha continuam nas 3
# primeiras colunas, unicas cuja ordem o restante do pipeline ja depende.
function Get-OpenTaskRows {
  param([string]$Content, [string]$SourcePath = "")
  $rows = @()
  $inSection = $false
  $headerSeen = $false
  $statusIdx = -1
  $issueIdx = -1
  $headerColCount = 0
  foreach ($line in ($Content -split "`r?`n")) {
    # Regex so com ASCII de proposito (mesma razao do aviso no topo do arquivo):
    # casa "Decomposicao de tarefas e dependencias" com ou sem acentuacao,
    # sem embutir bytes multibyte que dependeriam da codepage do sistema.
    if ($line -match '^## .*Decomposi.*de tarefas e depend') { $inSection = $true; continue }
    if ($inSection -and $line -match '^## ') { $inSection = $false }
    if ($inSection -and $line -match '^\|') {
      if ($line -match '^\|[-|\s]+\|?$') { continue }
      $trimmed = $line.Trim().Trim('|')
      $cols = $trimmed -split '\|' | ForEach-Object { $_.Trim() }
      if (-not $headerSeen) {
        $headerSeen = $true
        $headerColCount = $cols.Count
        for ($i = 0; $i -lt $cols.Count; $i++) {
          if ($cols[$i] -eq 'Status') { $statusIdx = $i }
          if ($cols[$i] -eq 'Issue GitHub') { $issueIdx = $i }
        }
        continue
      }
      if ($cols.Count -ne $headerColCount) {
        Write-Warning "Linha da tabela de decomposicao$(if ($SourcePath) { " em $SourcePath" }) tem $($cols.Count) colunas, cabecalho tem $headerColCount - provavel '|' literal/escapado dentro de uma celula deslocando colunas; linha ignorada em vez de reportar Status errado: $line"
        continue
      }
      if ($statusIdx -ge 0 -and $statusIdx -lt $cols.Count) {
        $status = $cols[$statusIdx] -replace '^\*+', ''
        if ($status -match $OpenTaskStatusPattern) {
          $issue = if ($issueIdx -ge 0 -and $issueIdx -lt $cols.Count) { $cols[$issueIdx] } else { "" }
          $rows += [PSCustomObject]@{ Id = $cols[0]; Tarefa = $cols[1]; Trilha = $cols[2]; Status = $cols[$statusIdx]; Issue = $issue }
        }
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
$allTaskRows = @()
$specsSemTrd = @()

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

    $trdFile = Join-Path $d.FullName "trd.md"
    $prdFile = Join-Path $d.FullName "prd.md"
    if (Test-Path $trdFile) {
      $content = Get-Content $trdFile -Raw
      foreach ($row in (Get-OpenTaskRows -Content $content -SourcePath $trdFile)) {
        $allTaskRows += [PSCustomObject]@{ Feature = $d.Name; Id = $row.Id; Tarefa = $row.Tarefa; Trilha = $row.Trilha; Status = $row.Status; Issue = $row.Issue }
      }
    } elseif (Test-Path $prdFile) {
      $specsSemTrd += $d.Name
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

Write-Host ""
Write-Host "Tarefas ainda nao implementadas (tabela de decomposicao do TRD):"
"{0,-28} | {1,-6} | {2,-42} | {3,-14} | {4,-14} | {5}" -f "Feature", "ID", "Tarefa", "Trilha", "Status", "Issue"
"-" * 130

$foundTask = $false
foreach ($row in $allTaskRows) {
  $foundTask = $true
  "{0,-28} | {1,-6} | {2,-42} | {3,-14} | {4,-14} | {5}" -f $row.Feature, $row.Id, $row.Tarefa, $row.Trilha, $row.Status, $row.Issue
}

if (-not $foundTask) {
  Write-Host "Nenhuma tarefa pendente de implementacao nos TRDs existentes."
}

if ($specsSemTrd.Count -gt 0) {
  Write-Host ""
  Write-Host "Specs com PRD aprovado mas sem TRD ainda (tarefas nao decompostas): $($specsSemTrd -join ', ')"
}
