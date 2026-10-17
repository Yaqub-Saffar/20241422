<#
.SYNOPSIS
    解析本轮报告版本号 N，显式优先、推断兜底。

.DESCRIPTION
    v7 新增。对应 SKILL.md 阶段 0 与铁律 12。
    v1~v6 的版本号靠"取 output\ 下最大版本号 +1"推断，目录被手动改动就会算错。
    本脚本按固定优先级解析，并打印取值来源，便于核对：

        ① -Version 显式传入        → 最优先
        ② 输入文件 front-matter 的 report_version: N
        ③ 都没有 → 推断 output\ 下最大版本号 +1（并提示这是推断值）

    只输出结果到一个变量供调用方使用；同时打印一行说明。
    单值输出模式（-Quiet）只打印数字，便于脚本捕获。

.PARAMETER Version
    显式版本号。给了就用它，不再推断。

.PARAMETER Input
    本周输入文件（input\weekNN.md）。用于读取 front-matter 的 report_version。

.PARAMETER Root
    仓库根目录。省略时取脚本上一级目录。

.PARAMETER Quiet
    只输出数字，不打印说明行。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\version.ps1 -Input input\week08.md
#>
[CmdletBinding()]
param(
    [int]$Version = 0,
    [string]$Input = '',
    [string]$Root = '',
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }

$n = 0
$src = ''
if ($Version -gt 0) {
    $n = $Version; $src = '命令行 -Version'
}
elseif ($Input -and (Test-Path -LiteralPath $Input)) {
    $head = (Get-Content -LiteralPath $Input -TotalCount 15 -Encoding UTF8) -join "`n"
    $m = [regex]::Match($head, '(?m)^\s*report_version\s*:\s*([0-9]+)\s*$')
    if ($m.Success) { $n = [int]$m.Groups[1].Value; $src = 'front-matter report_version' }
}
if ($n -le 0) {
    $outDir = Join-Path $Root 'output'
    if (Test-Path -LiteralPath $outDir) {
        $vers = Get-ChildItem -LiteralPath $outDir -Directory |
                ForEach-Object { if ($_.Name -match '^v(\d+)$') { [int]$Matches[1] } }
        if ($vers) { $n = (($vers | Measure-Object -Maximum).Maximum) + 1 }
        else { $n = 1 }
    } else { $n = 1 }
    $src = '推断（output\ 最大版本号 +1）'
}

if ($Quiet) { Write-Output $n }
else {
    Write-Host "[version] N=$n  来源：$src" -ForegroundColor Cyan
    if ($src -like '推断*') {
        Write-Host "[version] 注意：N 是推断值，请确认；建议用 -Version 或在输入 front-matter 写 report_version 显式指定" -ForegroundColor Yellow
    }
    Write-Output $n
}
