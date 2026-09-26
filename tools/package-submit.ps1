<#
.SYNOPSIS
    把人工审阅版报告打包成可直接上传到课程平台的提交件。

.DESCRIPTION
    老师平台要求文件名带学号、姓名、课程名与周次，所以从 human-edited.md
    复制出两份改名后的副本：

      submit\20241422 穆弈涵 《密码系统设计》.md
      submit\20241422 穆弈涵 《密码系统设计》第3周.pdf

    放在 submit\ 而不是就地改名，原因：
      - output\vN\ 里要保留 human-edited.md 原名，否则 git 历史里
        「AI 草稿 → 人工审阅版」的对应关系断了；
      - submit\ 作为一个暂存目录，一眼能看出「这才是要交的东西」。

    只复制，不移动。原件仍是唯一真源。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\package-submit.ps1 -Report output\v1\human-edited.md -Week 3

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\package-submit.ps1 -Report output\v1\human-edited.md -Week 3 -Course "信息安全系统设计"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Report,
    [Parameter(Mandatory = $true)][int]$Week,
    [string]$StudentId   = '20241422',
    [string]$StudentName = '穆弈涵',
    [string]$Course      = '密码系统设计'
)

$ErrorActionPreference = 'Stop'

$repoRoot   = Split-Path -Parent $PSScriptRoot
$reportPath = (Resolve-Path -LiteralPath $Report -ErrorAction Stop).Path
$stem       = [System.IO.Path]::GetFileNameWithoutExtension($reportPath)
$reportDir  = Split-Path -Parent $reportPath

# 提交件名里的书名号用中文全角，与老师模板一致；Windows 文件名非法字符是 \ / : * ? " < > |
$baseName = "$StudentId $StudentName 《$Course》"
$submitDir = Join-Path $repoRoot 'submit'
New-Item -ItemType Directory -Path $submitDir -Force | Out-Null

# 1) Markdown：文件名不带周次，与老师模板一致
$mdTarget = Join-Path $submitDir "$baseName.md"
Copy-Item -LiteralPath $reportPath -Destination $mdTarget -Force
Write-Host "[submit] Markdown: submit\$baseName.md" -ForegroundColor Green

# 2) PDF：文件名带周次。必须已导出，否则报错而不是静默跳过
$pdfSource = Join-Path $reportDir "$stem.pdf"
if (-not (Test-Path -LiteralPath $pdfSource)) {
    throw "找不到 $pdfSource。请先运行 tools\export.ps1 导出 PDF 再打包。"
}
$pdfTarget = Join-Path $submitDir "$baseName`第$($Week)周.pdf"
Copy-Item -LiteralPath $pdfSource -Destination $pdfTarget -Force
Write-Host "[submit] PDF:      submit\$baseName`第$($Week)周.pdf" -ForegroundColor Green

# 3) 基本自检：两份都在，且非空
foreach ($f in @($mdTarget, $pdfTarget)) {
    $len = (Get-Item -LiteralPath $f).Length
    if ($len -le 0) { throw "$f 是空文件，打包失败" }
}

Write-Host "[submit] 完成，共 2 个文件在 submit\ 下" -ForegroundColor Cyan
Write-Host "[submit] 上传到课程平台时选这两份，不要传 output\ 里的原件" -ForegroundColor Yellow
