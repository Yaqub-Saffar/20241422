<#
.SYNOPSIS
    把周报 Markdown 导出为 DOCX 与 PDF，并渲染其中的 Mermaid 思维导图为 PNG。

    .DESCRIPTION
    三步：
      1. 抽出 Markdown 中的 ```mermaid 代码块，用 mermaid-cli 渲染成 assets\*.png，
         并在原代码块前插入图片引用（老师要求「Mermaid 代码与截图」两者都要）。
      2. 用 Pandoc 导出 PDF（经由单文件 HTML + 本机 Edge 无头模式）。
      3. DOCX 默认**不生成**：老师只收 Markdown 与 PDF，多一种格式只是多一份
         可能在提交前忘更新的副本。需要时显式加 -Docx。

    .EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\export.ps1 -Report output\v1\human-edited.md

    .EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\export.ps1 -Report output\v1\human-edited.md -Docx
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Report,
    [string]$OutDir,
    [switch]$Docx,
    [switch]$SkipPdf
)

# 本脚本会调用 mmdc / pandoc / msedge 三个原生程序，它们都会往 stderr 写无关噪声
# （Git 的 "Ignore caches that are heterogeneous"、Edge 的 QQBrowser 导入告警等）。
# PowerShell 5.1 会把原生 stderr 提升为 ErrorRecord，配合 Stop 会导致脚本中断，
# 因此这里用 Continue，真正的失败一律显式 throw。
$ErrorActionPreference = 'Continue'

$repoRoot    = Split-Path -Parent $PSScriptRoot
$reportPath = (Resolve-Path -LiteralPath $Report -ErrorAction Stop).Path
$reportDir   = Split-Path -Parent $reportPath
$stem        = [System.IO.Path]::GetFileNameWithoutExtension($reportPath)
if (-not $OutDir) { $OutDir = $reportDir }

$assetsDir = Join-Path $repoRoot 'assets'
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
New-Item -ItemType Directory -Path $OutDir    -Force | Out-Null

function Write-Step($msg) { Write-Host "[export] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "[export] $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "[export] $msg" -ForegroundColor Yellow }

function Resolve-Executable([string]$name, [string[]]$candidates) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    return $null
}

$pandoc = Resolve-Executable 'pandoc' @(
    "$env:LOCALAPPDATA\Pandoc\pandoc.exe",
    "$env:LOCALAPPDATA\Programs\Pandoc\pandoc.exe",
    "C:\Program Files\Pandoc\pandoc.exe"
)

$mmdc = Resolve-Executable 'mmdc' @(
    "$env:APPDATA\npm\mmdc.cmd",
    "$env:APPDATA\npm\mmdc.ps1"
)

$edge = Resolve-Executable 'msedge' @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

# ---------------------------------------------------------------- 1. Mermaid
$text = [System.IO.File]::ReadAllText($reportPath, [System.Text.Encoding]::UTF8)
$mermaidPattern = '(?ms)^```mermaid[ \t]*\r?\n(.*?)^```[ \t]*$'
$matches = [regex]::Matches($text, $mermaidPattern)

if ($matches.Count -eq 0) {
    Write-Step '未发现 mermaid 代码块，跳过渲染'
} elseif (-not $mmdc) {
    Write-Warn2 '未找到 mmdc，跳过 Mermaid 渲染（npm i -g @mermaid-js/mermaid-cli）'
} else {
    Write-Step "发现 $($matches.Count) 个 mermaid 块，开始渲染"
    $puppeteerCfg = Join-Path $PSScriptRoot 'puppeteer-config.json'

    # 报告所在目录到 assets 的相对路径（用 MakeRelativeUri，避免中文路径与跨盘符出错）
    $assetsUri = New-Object System.Uri(($assetsDir.TrimEnd('\') + '\'))
    $reportUri = New-Object System.Uri(($reportDir.TrimEnd('\') + '\'))
    $relPrefix = $reportUri.MakeRelativeUri($assetsUri).ToString()
    if (-not $relPrefix.EndsWith('/')) { $relPrefix += '/' }

    # 从后往前替换，避免相同代码块被重复插入图片
    for ($i = $matches.Count - 1; $i -ge 0; $i--) {
        $m = $matches[$i]
        $name = "$stem-mermaid-$($i + 1)"
        $png  = Join-Path $assetsDir "$name.png"
        $mmd  = Join-Path $env:TEMP "$name.mmd"

        [System.IO.File]::WriteAllText($mmd, $m.Groups[1].Value, (New-Object System.Text.UTF8Encoding($false)))

        $mmdcArgs = @('-i', $mmd, '-o', $png, '-b', 'white', '--size', '1600', '-s', '2')
        & $mmdc @mmdcArgs 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0 -and (Test-Path -LiteralPath $puppeteerCfg)) {
            Write-Warn2 "mmdc 直接调用失败，改用本机 Edge 重试（第 $($i + 1) 个）"
            & $mmdc @('-p', $puppeteerCfg) @mmdcArgs 2>$null | Out-Null
        }

        if (Test-Path -LiteralPath $png) {
            # alt 文字不要用 $name（含文件名，Word 会把它当图注渲染出来，
            # 成品里就会露出 "human-edited-mermaid-1" 这种内部命名）
            $alt = if ($matches.Count -gt 1) { "学习思维导图 $($i + 1)" } else { '学习思维导图' }
            $figure = "`r`n![$alt]($relPrefix$name.png)`r`n"
            $text = $text.Substring(0, $m.Index) + $figure + $text.Substring($m.Index)
            Write-Ok "渲染完成: assets\$name.png"
        } else {
            Write-Warn2 "第 $($i + 1) 个 mermaid 块渲染失败，保留代码块"
        }
        Remove-Item -LiteralPath $mmd -Force -ErrorAction SilentlyContinue
    }

    $patchedPath = Join-Path $env:TEMP "$stem.with-figures.md"
    [System.IO.File]::WriteAllText($patchedPath, $text, (New-Object System.Text.UTF8Encoding($false)))
}

# 选择用于导出的源文件
$sourcePath = if ($matches.Count -gt 0 -and $mmdc) { $patchedPath } else { $reportPath }

# ---------------------------------------------------------------- 2. DOCX
# pandoc 在 --standalone 下会从文件名推断标题，并在正文最上方插入一个 Title 样式的
# 标题块（PDF 里表现为顶端多出一行 human-edited）。报告 Markdown 本身已有
# `# 密码系统设计`，再插一层是重复内容，所以显式把 title 置空抑制掉。
$docxPath = Join-Path $OutDir "$stem.docx"
if (-not $Docx) {
    Write-Step '跳过 DOCX（默认不生成，需要时加 -Docx）'
} else {
    if (-not $pandoc) {
        Write-Warn2 '未找到 pandoc，跳过 DOCX（winget install --id JohnMacFarlane.Pandoc -e）'
    } else {
        Write-Step '导出 DOCX ...'
        & $pandoc --from=markdown --to=docx --standalone --resource-path="$reportDir;$repoRoot" `
                  --metadata title="" -o $docxPath $sourcePath
        if ($LASTEXITCODE -eq 0) { Write-Ok "DOCX: $docxPath" } else { Write-Warn2 'DOCX 导出失败' }
    }
}

# ---------------------------------------------------------------- 3. PDF
if (-not $SkipPdf) {
    if (-not $pandoc) {
        Write-Warn2 '未找到 pandoc，跳过 PDF'
    } elseif (-not $edge) {
        Write-Warn2 '未找到 Microsoft Edge，跳过 PDF（可手动用 WPS 打开 DOCX 导出）'
    } else {
        Write-Step '导出 PDF ...'
        $htmlPath = Join-Path $env:TEMP "$stem.html"
        $cssPath  = Join-Path $PSScriptRoot 'report.css'

        # title 置空：抑制 pandoc 推断出的标题块（详见上方 2. DOCX 处的说明）
        & $pandoc --from=markdown --to=html5 --standalone --embed-resources `
                  --resource-path="$reportDir;$repoRoot" `
                  --css="$cssPath" --metadata title="" `
                  -o $htmlPath $sourcePath

        if ($LASTEXITCODE -eq 0) {
            $pdfPath = Join-Path $OutDir "$stem.pdf"
            $htmlUri = (New-Object System.Uri($htmlPath)).AbsoluteUri
            # 注意：Edge 的 --print-to-pdf 只接受原始文件系统路径，
            # 传 file:// URI 会静默失败（exit=0 但不产出文件）。输入侧才用 URI。
            # 一次性唯一 profile 目录：避免复用本机正在运行的 Edge 实例。
            $profileDir = Join-Path $env:TEMP ("opencode-edge-profile-" + [guid]::NewGuid().ToString('N'))
            $edgeArgs = @('--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                          '--no-first-run', '--no-default-browser-check',
                          "--user-data-dir=$profileDir",
                          "--print-to-pdf=$pdfPath", $htmlUri)
            # Start-Process 会把数组用空格拼成一条命令行再重新切分：含空格的路径
            # （如报告文件名 20241422穆弈涵 skill迭代.pdf）会被切成两个参数，
            # Edge 误判为多个目标而报 Multiple targets are not supported in headless mode。
            # 故先给含空格的参数加引号，再作为单条字符串传入。
            $edgeArgLine = ($edgeArgs | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join ' '
            $proc = Start-Process -FilePath $edge -ArgumentList $edgeArgLine -NoNewWindow -PassThru -Wait
            if (Test-Path -LiteralPath $pdfPath) {
                Write-Ok "PDF: $pdfPath"
            } else {
                Write-Warn2 "Edge 打印 PDF 失败（exit=$($proc.ExitCode)），可手动用 WPS 打开 DOCX 导出"
            }
            Remove-Item -LiteralPath $htmlPath -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $profileDir -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Warn2 'HTML 中间文件生成失败'
        }
    }
}

Write-Step '完成'
