<#
.SYNOPSIS
    把 skill\vN 整个目录同步为 opencode 的当前运行版本。

.DESCRIPTION
    skill\vN\ 是 Skill 的唯一真源，opencode 只会加载
    .opencode\skills\preview-report\ 下的文件，因此每轮迭代定稿后需要同步一次。
    真源与运行副本不应分别编辑。

    注意：必须同步整个目录而不只是 SKILL.md。SKILL.md 里用相对路径引用
    references\*.md，只复制 SKILL.md 会让运行副本缺少这些文件，
    Skill 执行到读 references 时直接失败。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\use-version.ps1 -Version 3
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][int]$Version
)

$ErrorActionPreference = 'Stop'

$repoRoot  = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot "skill\v$Version"
$source    = Join-Path $sourceDir 'SKILL.md'
$targetDir = Join-Path $repoRoot '.opencode\skills\preview-report'

if (-not (Test-Path -LiteralPath $source)) {
    throw "找不到 $source"
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
Copy-Item -LiteralPath $source -Destination (Join-Path $targetDir 'SKILL.md') -Force

# references\ 必须一起同步：SKILL.md 用相对路径引用它们
$srcRefs = Join-Path $sourceDir 'references'
$dstRefs = Join-Path $targetDir 'references'
if (Test-Path -LiteralPath $srcRefs) {
    if (Test-Path -LiteralPath $dstRefs) { Remove-Item -LiteralPath $dstRefs -Recurse -Force }
    Copy-Item -LiteralPath $srcRefs -Destination $dstRefs -Recurse -Force
    $refCount = (Get-ChildItem -LiteralPath $dstRefs -File -Recurse).Count
} else {
    $refCount = 0
}

# 同步后自检：SKILL.md 里提到的 references 文件是否都真的到位
$text = Get-Content -LiteralPath (Join-Path $targetDir 'SKILL.md') -Raw -Encoding UTF8
$referenced = [regex]::Matches($text, 'references/([A-Za-z0-9\-_]+\.md)') |
              ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$missing = @($referenced | Where-Object { -not (Test-Path -LiteralPath (Join-Path $dstRefs $_)) })

$versionLine = (Get-Content -LiteralPath $source -TotalCount 12 -Encoding UTF8 |
                Where-Object { $_ -match '^\s*version:' }) -join ''
Write-Host "[use-version] 已同步 skill\v$Version -> .opencode\skills\preview-report\  $versionLine" -ForegroundColor Green
Write-Host "[use-version] references\ 已同步 $refCount 个文件（SKILL.md 引用了 $($referenced.Count) 个）" -ForegroundColor Green
if ($missing.Count -gt 0) {
    Write-Host "[use-version] 警告：SKILL.md 引用了这些文件但运行副本里没有：$($missing -join ', ')" -ForegroundColor Yellow
}
Write-Host '[use-version] 请重启 opencode 使新 Skill 生效' -ForegroundColor Yellow
