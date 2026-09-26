<#
.SYNOPSIS
    把人工审阅版报告打包成可直接上传到课程平台的提交件。

.DESCRIPTION
    老师平台要求文件名带学号、姓名、课程名与周次，所以从 human-edited.md
    复制出两份改名后的副本：

      submit\20241422 穆弈涵 《密码系统设计》.md
      submit\20241422 穆弈涵 《密码系统设计》第三周.pdf

    两种格式都要（md 与 pdf），所以默认就产出两份。

    放在 submit\ 而不是就地改名，原因：
      - output\vN\ 里要保留 human-edited.md 原名，否则 git 历史里
        「AI 草稿 → 人工审阅版」的对应关系断了；
      - submit\ 作为一个暂存目录，一眼能看出「这才是要交的东西」。

    只复制，不移动。原件仍是唯一真源。

.PARAMETER Desktop
    额外复制一份到桌面，方便直接拖进浏览器上传。

.PARAMETER Clean
    清掉桌面上该周的两份副本。上传成功、确认无误后再执行。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\package-submit.ps1 -Report output\v1\human-edited.md -Week 3 -Desktop

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\package-submit.ps1 -Report output\v1\human-edited.md -Week 3 -Clean

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\package-submit.ps1 -Report output\v1\human-edited.md -Week 3 -Course "信息安全系统设计"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Report,
    [Parameter(Mandatory = $true)][int]$Week,
    [string]$StudentId   = '20241422',
    [string]$StudentName = '穆弈涵',
    [string]$Course      = '密码系统设计',
    [switch]$Desktop,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

# 周次在文件名里用汉字（第三周），不是阿拉伯数字（3周）
$cnDigits = @('零', '一', '二', '三', '四', '五', '六', '七', '八', '九')
if ($Week -lt 1 -or $Week -gt 99) { throw "周次 $Week 超出 1-99，无法转成汉字" }
if ($Week -lt 10) {
    $weekCn = $cnDigits[$Week]
} else {
    $tens = [int]($Week / 10)
    $ones = $Week % 10
    # 十位是 1 时不写前导「一」：10 -> 十，11 -> 十一，15 -> 十五
    $weekCn = if ($tens -eq 1) { '十' } else { $cnDigits[$tens] + '十' }
    if ($ones -gt 0) { $weekCn += $cnDigits[$ones] }
}

$repoRoot   = Split-Path -Parent $PSScriptRoot
$reportPath = (Resolve-Path -LiteralPath $Report -ErrorAction Stop).Path
$stem       = [System.IO.Path]::GetFileNameWithoutExtension($reportPath)
$reportDir  = Split-Path -Parent $reportPath

# 提交件名里的书名号用中文全角，与老师模板一致；Windows 文件名非法字符是 \ / : * ? " < > |
$baseName = "$StudentId $StudentName 《$Course》"
$mdName   = "$baseName.md"
$pdfName  = "$baseName`第${weekCn}周.pdf"

$submitDir = Join-Path $repoRoot 'submit'
New-Item -ItemType Directory -Path $submitDir -Force | Out-Null

# ---- 清桌面模式：只删桌面上该周的两份副本，submit\ 里的留档不动
if ($Clean) {
    # 注意：局部变量不能叫 $desktop——PowerShell 变量名不区分大小写，
    # 赋字符串路径会把同名的 [switch]$Desktop 参数覆盖掉，回转类型时直接抛异常。
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $removed = 0
    foreach ($n in @($mdName, $pdfName)) {
        $p = Join-Path $desktopPath $n
        if (Test-Path -LiteralPath $p) {
            Remove-Item -LiteralPath $p -Force
            Write-Host "[submit] 已删除桌面副本: $n" -ForegroundColor Yellow
            $removed++
        }
    }
    if ($removed -eq 0) { Write-Host '[submit] 桌面上没有该周文件，无需清理' -ForegroundColor DarkGray }
    else { Write-Host "[submit] 共清理 $removed 个文件" -ForegroundColor Cyan }
    return
}

# ---- 打包模式
# 1) Markdown：文件名不带周次，与老师模板一致
$mdTarget = Join-Path $submitDir $mdName
Copy-Item -LiteralPath $reportPath -Destination $mdTarget -Force
Write-Host "[submit] Markdown: submit\$mdName" -ForegroundColor Green

# 2) PDF：文件名带周次。必须已导出，否则报错而不是静默跳过
$pdfSource = Join-Path $reportDir "$stem.pdf"
if (-not (Test-Path -LiteralPath $pdfSource)) {
    throw "找不到 $pdfSource。请先运行 tools\export.ps1 导出 PDF 再打包。"
}
$pdfTarget = Join-Path $submitDir $pdfName
Copy-Item -LiteralPath $pdfSource -Destination $pdfTarget -Force
Write-Host "[submit] PDF:      submit\$pdfName" -ForegroundColor Green

# 3) 基本自检：两份都在，且非空
foreach ($f in @($mdTarget, $pdfTarget)) {
    $len = (Get-Item -LiteralPath $f).Length
    if ($len -le 0) { throw "$f 是空文件，打包失败" }
}

# 4) 可选：再复制一份到桌面
if ($Desktop) {
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    foreach ($src in @($mdTarget, $pdfTarget)) {
        Copy-Item -LiteralPath $src -Destination (Join-Path $desktopPath (Split-Path -Leaf $src)) -Force
    }
    Write-Host "[submit] 已复制 2 份到桌面：$desktopPath" -ForegroundColor Cyan
    Write-Host "[submit] 上传并确认无误后，运行同命令加 -Clean 清掉桌面副本" -ForegroundColor Yellow
} else {
    Write-Host "[submit] 完成，共 2 个文件在 submit\ 下" -ForegroundColor Cyan
}
