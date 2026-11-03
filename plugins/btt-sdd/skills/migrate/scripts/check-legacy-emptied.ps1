# Confirma mecanicamente que o passo 9 de .claude/skills/sdd-migrate/SKILL.md (esvaziar o corpo
# do arquivo legado, mantendo so titulo + banner de migracao) foi de fato executado - em vez de
# depender de quem roda a migracao lembrar de fazer isso sozinho.
#
# Uso: powershell -File scripts/check-legacy-emptied.ps1 -File <arquivo-legado>
# Saida: "OK" e exit 0 se so titulo + banner sobram; senao lista as linhas extras e exit 1.
#
# Nasceu da issue #602 (asengardeon/btt-sdd-pipeline): todas as execucoes anteriores de
# /sdd-migrate num projeto consumidor fizeram a transformacao para v2 corretamente, mas nenhuma
# esvaziou o arquivo legado - 75 arquivos com ~78.700 linhas de conteudo original duplicado atras
# do banner, so percebido por auditoria manual. O passo 9 ser so prosa, sem verificacao propria,
# permitiu a lacuna silenciosa em toda execucao anterior.
#
# Nota: strings deste arquivo evitam acentos de proposito (mesmo padrao dos demais .ps1 deste
# pipeline) - .ps1 sem BOM e lido pela codepage do sistema no Windows PowerShell 5.1.

param([Parameter(Mandatory = $true)][string]$File)

if (-not (Test-Path $File)) {
  Write-Host "Arquivo nao encontrado: $File"
  exit 2
}

$lines = Get-Content $File -Encoding UTF8
$extra = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
  $line = $lines[$i]
  $lineNum = $i + 1
  if ($lineNum -eq 1 -and $line -match '^#\s') { continue }
  if ($line -match '^\s*$') { continue }
  if ($line -match '^>') { continue }
  $extra += "  ${lineNum}: $line"
}

if ($extra.Count -gt 0) {
  Write-Host "FALHOU - conteudo extra alem de titulo/banner em $File`:"
  $extra | ForEach-Object { Write-Host $_ }
  exit 1
}

Write-Host "OK - so titulo + banner em $File"
exit 0
