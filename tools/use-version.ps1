<#
.SYNOPSIS
    把 skill\vN\SKILL.md 同步为 opencode 的当前运行版本。

.DESCRIPTION
    skill\vN\SKILL.md 是 Skill 的唯一真源，opencode 只会加载
    .opencode\skills\preview-report\SKILL.md，因此每轮迭代定稿后需要同步一次。
    两个文件不应分别编辑。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\use-version.ps1 -Version 3
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][int]$Version
)

$ErrorActionPreference = 'Stop'

$repoRoot  = Split-Path -Parent $PSScriptRoot
$source    = Join-Path $repoRoot "skill\v$Version\SKILL.md"
$targetDir = Join-Path $repoRoot '.opencode\skills\preview-report'
$target    = Join-Path $targetDir 'SKILL.md'

if (-not (Test-Path -LiteralPath $source)) {
    throw "找不到 $source"
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force

$versionLine = (Get-Content -LiteralPath $source -TotalCount 8 -Encoding UTF8 |
                Where-Object { $_ -match '^version:' }) -join ''
Write-Host "[use-version] 已同步 skill\v$Version\SKILL.md -> .opencode\skills\preview-report\SKILL.md  $versionLine" -ForegroundColor Green
Write-Host '[use-version] 请重启 opencode 使新 Skill 生效' -ForegroundColor Yellow
