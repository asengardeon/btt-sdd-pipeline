# Compara os casos de uso listados na secao 6 (Casos de uso) do TRD de uma
# feature contra o codigo real implementado, sem precisar reler o TRD inteiro
# e grepar classe por classe manualmente. Usado por
# .claude/skills/sdd-gap-report.
#
# Uso: powershell -File scripts/sdd-gap-report.ps1 -Slug <slug> [-SearchPaths <caminho1>,<caminho2>,...]
#   -Slug         - obrigatorio: specs/<slug>/trd.md precisa existir.
#   -SearchPaths  - opcional; substitui a deteccao automatica (src/ e, se
#                   existir, frontend/) quando o projeto usa outra convencao
#                   de pastas (ex.: src/app/Application/UseCases/ no Laravel).
#
# Saida: aproximacao best-effort via regex sobre a convencao de formatacao da
# tabela "Criterio de aceite (PRD) | Caso de uso | Ports usados" de
# specs/_template/trd.template.md. Se a tabela fugir muito do formato padrao,
# isso e sinalizado e o TRD precisa ser lido manualmente.
#
# Nota sobre frontend: nenhum template deste pipeline define hoje uma tabela
# equivalente de "telas/rotas" para o frontend (e uma decisao do
# `architect`, caso a caso, nao um formato fixo) - por isso este script nao
# tenta parsear uma. Em compensacao, frontend/ entra por padrao nas raizes de
# busca.
#
# Nota: strings deste arquivo evitam acentos de proposito - .ps1 sem BOM e
# lido pela codepage do sistema no Windows PowerShell 5.1, e caracteres
# multibyte podem quebrar o parser ou sair como mojibake na saida.

param(
  [Parameter(Mandatory = $true)][string]$Slug,
  [string[]]$SearchPaths
)

$Trd = "specs/$Slug/trd.md"
if (-not (Test-Path $Trd)) {
  Write-Host "TRD nao encontrado: $Trd"
  exit 1
}

$roots = @()
if ($SearchPaths -and $SearchPaths.Count -gt 0) {
  $roots = $SearchPaths
} else {
  if (Test-Path "src") { $roots += "src" }
  if (Test-Path "frontend") { $roots += "frontend" }
}
if ($roots.Count -eq 0) {
  Write-Host "Nenhum diretorio de codigo encontrado (src/ ou frontend/) e nenhum -SearchPaths informado."
  exit 1
}

$ExcludeDirs = @(".git", "node_modules", "vendor", "dist", "build", ".venv", "venv", "__pycache__", ".next", "target")

function Get-UseCaseRows {
  param([string]$Content)
  $rows = @()
  $inSection = $false
  foreach ($line in ($Content -split "`r?`n")) {
    if ($line -match '^## 6\. Casos de uso') { $inSection = $true; continue }
    if ($inSection -and $line -match '^## ') { $inSection = $false }
    if ($inSection -and $line -match '^\|') {
      $trimmed = $line.Trim().Trim('|')
      $cols = $trimmed -split '\|' | ForEach-Object { $_.Trim() }
      if ($cols.Count -ge 2 -and $cols[1] -notmatch '^-+$' -and $cols[1].ToLower() -ne 'caso de uso') {
        $rows += [PSCustomObject]@{ Criterio = $cols[0]; CasoDeUso = $cols[1] }
      }
    }
  }
  return $rows
}

function Find-Evidence {
  param([string]$ClassName, [string[]]$Roots)
  foreach ($root in $Roots) {
    if (-not (Test-Path $root)) { continue }
    $hit = Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object {
        $full = $_.FullName -replace '\\', '/'
        $skip = $false
        foreach ($ex in $ExcludeDirs) { if ($full -match "/$([regex]::Escape($ex))/") { $skip = $true } }
        if ($full -match '/tests?/' -or $full -match '\.(spec|test)\.') { $skip = $true }
        -not $skip
      } |
      Select-String -SimpleMatch $ClassName -List -ErrorAction SilentlyContinue |
      Select-Object -First 1
    if ($hit) { return $hit.Path }
  }
  return $null
}

$content = Get-Content $Trd -Raw -Encoding UTF8
$rows = Get-UseCaseRows -Content $content

"{0,-38} | {1,-38} | {2,-12} | {3}" -f "Caso de uso", "Criterio de aceite (US)", "Implementado", "Evidencia"
"-" * 130

if ($rows.Count -eq 0) {
  Write-Host ""
  Write-Host "Nenhuma linha reconhecida na secao 6 (Casos de uso) de $Trd - a tabela pode ter fugido do formato padrao (specs/_template/trd.template.md); leia o TRD manualmente."
  exit 0
}

foreach ($row in $rows) {
  $m = [regex]::Match($row.CasoDeUso, '`([^`]+)`')
  $className = if ($m.Success) { $m.Groups[1].Value } else { $row.CasoDeUso }

  $evidence = Find-Evidence -ClassName $className -Roots $roots
  if ($evidence) { $impl = "sim" } else { $impl = "NAO"; $evidence = "(nenhum arquivo encontrado)" }

  "{0,-38} | {1,-38} | {2,-12} | {3}" -f $className, $row.Criterio, $impl, $evidence
}

Write-Host ""
Write-Host ("Raizes de busca usadas: " + ($roots -join ", "))
Write-Host "'NAO' significa que o nome do caso de uso nao apareceu (via busca de texto) em nenhum arquivo dessas raizes - confirme manualmente antes de tratar como nao implementado, a busca nao entende refactors que renomeiam a classe."
