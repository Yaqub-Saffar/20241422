<#
.SYNOPSIS
    对一篇预习报告草稿（generated.md）跑结构性机检，输出 PASS/FAIL。

.DESCRIPTION
    v5 新增。对应 SKILL.md 铁律 10「导出前必过机检」。
    v2~v4 的自查清单靠"人/模型自觉"，清单越长越依赖记性。本脚本把其中
    「结构性、可判定」的项落成一条命令，作为导出前的硬关卡。

    v6 起阈值不再写死：从 report.config.yml 读取（见 -Config），
    复杂章节可放宽导图节点字数/子节点数/层数上限。

    只写可判定的项；语义类判断（并列项是否打包、经验总结是否下到根因）
    仍由人工完成，脚本不越权。

.PARAMETER Report
    待检查的报告 markdown 路径。

.PARAMETER SelfReview
    self-review.md 路径。省略时默认取报告同目录下的 self-review.md。

.PARAMETER Week
    期望的周次（阿拉伯或汉字均可）。省略时不校验具体周次，只校验格式。

.PARAMETER Config
    report.config.yml 路径。省略时默认取脚本上一级目录的 report.config.yml；
    该文件不存在则用内置默认值（节点 ≤12 字、每分支 ≤6 子节点、层数 ≤5）。

.PARAMETER Final
    v7 新增。检查"定稿"（human-edited.md）时使用：此时人工已解除全部待确认锚点，
    第 7 项改为断言正文锚点数为 0，不再与 self-review.md 比对行数。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\check-report.ps1 -Report output\v6\generated.md -Week 7

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\check-report.ps1 -Report output\v6\generated.md -Config report.config.yml

.NOTES
    退出码：0 = 全部 PASS；1 = 存在 FAIL。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Report,
    [string]$SelfReview,
    [string]$Week = '',
    [string]$Config = '',
    [switch]$Final
)

$ErrorActionPreference = 'Stop'

# ---- 读取配置（v6 新增阈值可配；v7 增加校验：非法值回退默认、未知键报警） ----
$maxNodeChars = 12
$maxChildren = 6
$maxDepth = 5
$cfgGroupBySection = $true
$cfgGroupThreshold = 3
$cfgWarnings = New-Object System.Collections.Generic.List[string]
if (-not $Config) { $Config = Join-Path (Split-Path -Parent $PSScriptRoot) 'report.config.yml' }
$cfgUsed = '内置默认'
$knownKeys = @('max_node_chars', 'max_children', 'max_depth', 'group_by_section', 'group_threshold')
if (Test-Path -LiteralPath $Config) {
    $cfgUsed = (Resolve-Path -LiteralPath $Config).Path
    foreach ($line in (Get-Content -LiteralPath $Config -Encoding UTF8)) {
        $l = ($line -replace '#.*$', '').Trim()
        if ($l -eq '' -or $l -notmatch ':') { continue }
        $k = ($l -split ':', 2)[0].Trim()
        $v = ($l -split ':', 2)[1].Trim()
        if ($v -eq '') { continue }   # 段标题（如 mindmap:），不是键值对
        if ($knownKeys -notcontains $k) {
            $cfgWarnings.Add("未知配置键 '$k'（可能拼写错误），已忽略")
            continue
        }
        if ($k -eq 'group_by_section') {
            if ($v -match '^(true|false)$') { $cfgGroupBySection = ($v -eq 'true') }
            else { $cfgWarnings.Add("键 group_by_section 的值 '$v' 不是 true/false，已回退默认 true") }
            continue
        }
        $tmp = 0
        if (-not [int]::TryParse($v, [ref]$tmp)) {
            $cfgWarnings.Add("键 $k 的值 '$v' 不是整数，已回退默认")
            continue
        }
        if ($tmp -le 0) {
            $cfgWarnings.Add("键 $k 的值 $tmp 不是正数，已回退默认")
            continue
        }
        switch ($k) {
            'max_node_chars' { $maxNodeChars = $tmp }
            'max_children' { $maxChildren = $tmp }
            'max_depth' { $maxDepth = $tmp }
            'group_threshold' { $cfgGroupThreshold = $tmp }
        }
    }
}

if (-not (Test-Path -LiteralPath $Report)) { throw "找不到报告文件：$Report" }
$text = Get-Content -LiteralPath $Report -Raw -Encoding UTF8

if (-not $SelfReview) {
    $SelfReview = Join-Path (Split-Path -Parent (Resolve-Path -LiteralPath $Report)) 'self-review.md'
}

$results = New-Object System.Collections.Generic.List[object]
function Add-Result([string]$id, [string]$name, [bool]$ok, [string]$detail) {
    $results.Add([pscustomobject]@{ Id = $id; Name = $name; Ok = $ok; Detail = $detail })
}

# 把 -Week 归一成"阿拉伯或汉字都认"的片段（报告习惯写汉字，如「第六周」）
$cnNum = @{ '1' = '一'; '2' = '二'; '3' = '三'; '4' = '四'; '5' = '五'; '6' = '六'; '7' = '七'; '8' = '八'; '9' = '九'; '10' = '十' }
if ([string]::IsNullOrEmpty($Week)) {
    $weekAlt = '[一二三四五六七八九十百零0-9]+'
} elseif ($cnNum.ContainsKey($Week)) {
    $weekAlt = '(?:' + [regex]::Escape($Week) + '|' + $cnNum[$Week] + ')'
} else {
    $weekAlt = [regex]::Escape($Week)
}

# ---- [1] 五章标题齐全且顺序正确 ----
$markers = @(
    @{ L = '一级标题'; P = [regex]::Escape('# 密码系统设计') },
    @{ L = '周次标题'; P = '## 第\s*' + $weekAlt + '\s*周预习报告' },
    @{ L = '学习内容'; P = [regex]::Escape('### 学习内容') },
    @{ L = 'AI 总结'; P = [regex]::Escape('### AI 对学习内容的总结') },
    @{ L = '反思与补充'; P = [regex]::Escape('### 对 AI 总结的反思与补充') },
    @{ L = '实践问题'; P = [regex]::Escape('### 学习实践过程遇到的问题与解决方式') },
    @{ L = '参考资料'; P = [regex]::Escape('## 参考资料') },
    @{ L = '思维导图'; P = [regex]::Escape('### 学习思维导图') }
)
$positions = @()
$cursor = 0
$order_ok = $true
$missing = @()
foreach ($m in $markers) {
    $mt = [regex]::Match($text.Substring($cursor), $m.P)
    if (-not $mt.Success) { $order_ok = $false; $missing += $m.L; continue }
    $positions += ($cursor + $mt.Index)
    $cursor = $cursor + $mt.Index + $mt.Length
}
Add-Result 1 '五章标题齐全且顺序正确' $order_ok $(if ($order_ok) { '全部命中' } else { '缺失或顺序错：' + ($missing -join '、') })

# ---- [2] 无 ⚠️待核实 残留 ----
$pending = ([regex]::Matches($text, '待核实')).Count
$srExists = Test-Path -LiteralPath $SelfReview
Add-Result 2 '无 待核实 残留' ($pending -eq 0) $(if ($pending -eq 0) { '0 处' } else { "仍有 $pending 处，需转入待确认清单" })

# ---- [3] 思维导图根节点 ----
$reRoot = 'root\(\(\s*密码系统设计第\s*' + $weekAlt + '\s*周\s*\)\)'
$rootOk = [regex]::IsMatch($text, $reRoot)
$rootDetail = if ($rootOk) { '匹配' } else { '未找到形如 root((密码系统设计第N周)) 的根节点' }
Add-Result 3 '思维导图根节点格式' $rootOk $rootDetail

# ---- [4] 导图节点文案 <= max_node_chars（中文按字、连续西文按 1 个词计） ----
function Get-NodeWeight([string]$s) {
    $s = $s.Trim()
    if ($s -match '^root\(') { return $null }
    $count = 0; $i = 0
    while ($i -lt $s.Length) {
        $code = [int][char]$s[$i]
        if ($code -ge 0x4E00 -and $code -le 0x9FFF) { $count++; $i++ }
        elseif ($s[$i] -match '[A-Za-z0-9]') {
            while ($i -lt $s.Length -and $s[$i] -match '[A-Za-z0-9]') { $i++ }
            $count++
        } else { $i++ }
    }
    return $count
}
$overNodes = New-Object System.Collections.Generic.List[string]
$mm = [regex]::Match($text, '(?s)```mermaid\s*(.*?)```')
if ($mm.Success) {
    foreach ($line in ($mm.Groups[1].Value -split "`n")) {
        $t = $line.Trim()
        if ($t -eq '' -or $t -eq 'mindmap') { continue }
        $w = Get-NodeWeight $t
        if ($null -ne $w -and $w -gt $maxNodeChars) { $overNodes.Add("$t ($w)") }
    }
    Add-Result 4 "导图节点文案 <= $maxNodeChars 字" ($overNodes.Count -eq 0) $(if ($overNodes.Count -eq 0) { '全部达标（上限来自配置）' } else { '超长：' + ($overNodes -join '、') })
} else {
    Add-Result 4 "导图节点文案 <= $maxNodeChars 字" $false '未找到 mermaid 代码块'
}

# ---- [5] 无空话黑名单 ----
$blacklist = @('随着科技的飞速发展', '综上所述', '在当今社会', '总而言之', '值得注意的是', '不难看出', '相信随着技术进步')
$hits = @($blacklist | Where-Object { $text.Contains($_) })
Add-Result 5 '无空话黑名单词' ($hits.Count -eq 0) $(if ($hits.Count -eq 0) { '0 处' } else { '命中：' + ($hits -join '、') })

# ---- [6] 缩写首现是否带括号（近似判定） ----
$watch = @('OAEP', 'HMAC', 'PKI', 'CA', 'IV', 'TLS', 'ZUC')
$badAbbr = New-Object System.Collections.Generic.List[string]
foreach ($abbr in $watch) {
    $re = [regex]::Match($text, "\b$abbr\b")
    if (-not $re.Success) { continue }
    $p = $re.Index
    $lo = [Math]::Max(0, $p - 50); $hi = [Math]::Min($text.Length, $p + 50)
    $window = $text.Substring($lo, $hi - $lo)
    if (-not $window.Contains('（')) { $badAbbr.Add($abbr) }
}
Add-Result 6 '缩写首现带中英对照（近似）' ($badAbbr.Count -eq 0) $(if ($badAbbr.Count -eq 0) { '全部命中括号' } else { '首现未见括号：' + ($badAbbr -join '、') })

# ---- [7] 待确认锚点数 == self-review 表行数（-Final：终稿应已解除全部锚点） ----
$anchorCount = ([regex]::Matches($text, '<!--\s*待确认')).Count
if ($Final) {
    Add-Result 7 '终稿已解除全部锚点' ($anchorCount -eq 0) "终稿残留锚点 $anchorCount 处（应为 0）"
} elseif ($srExists) {
    $srText = Get-Content -LiteralPath $SelfReview -Raw -Encoding UTF8
    $rowCount = ([regex]::Matches($srText, '(?m)^\|\s*[0-9]+\s*\|')).Count
    $anchorOk = ($anchorCount -eq $rowCount)
    Add-Result 7 '锚点数 == self-review 行数' $anchorOk "正文 $anchorCount 处 vs 清单 $rowCount 行"
} else {
    Add-Result 7 '锚点数 == self-review 行数' ($anchorCount -eq 0) "未找到 self-review.md；正文锚点 $anchorCount 处"
}

# ---- [8] 必备标题存在 ----
$required = @('我的补充', '经验总结', '出现环境', '解决过程')
$missReq = @($required | Where-Object { -not $text.Contains($_) })
Add-Result 8 '必备标题存在' ($missReq.Count -eq 0) $(if ($missReq.Count -eq 0) { '全部存在' } else { '缺失：' + ($missReq -join '、') })

# ---- [9] 导图分支节点数与层数在上限内（v6：阈值来自配置） ----
if ($mm.Success) {
    $stack = @{}          # level -> node名称
    $childCount = @{}     # node名称 -> 直接子节点数
    $maxLevelSeen = 0
    foreach ($line in ($mm.Groups[1].Value -split "`n")) {
        if ($line.Trim() -eq '' -or $line.Trim() -eq 'mindmap') { continue }
        $indent = $line.Length - $line.TrimStart().Length
        $node = $line.Trim()
        $level = [Math]::Floor($indent / 4)
        if ($node -match '^root\(') { $level = 0 }
        if ($level -gt $maxLevelSeen) { $maxLevelSeen = $level }
        if ($node -notmatch '^root\(') {
            $parent = $stack[$level - 1]
            if ($null -ne $parent) {
                if (-not $childCount.ContainsKey($parent)) { $childCount[$parent] = 0 }
                $childCount[$parent]++
            }
        }
        $stack[$level] = $node
    }
    $overChild = @($childCount.Keys | Where-Object { $childCount[$_] -gt $maxChildren } | ForEach-Object { "$_($($childCount[$_]))" })
    $depthOk = ($maxLevelSeen -le $maxDepth)
    $childOk = ($overChild.Count -eq 0)
    $ok9 = $depthOk -and $childOk
    $d9 = "最大层数 $maxLevelSeen/$maxDepth"
    if (-not $childOk) { $d9 += '；分支超限：' + ($overChild -join '、') + "（上限 $maxChildren）" }
    Add-Result 9 '导图分支数/层数在上限内' $ok9 $d9
} else {
    Add-Result 9 '导图分支数/层数在上限内' $false '未找到 mermaid 代码块'
}

# ---- 输出 ----
Write-Host ''
Write-Host "check-report  报告：$Report" -ForegroundColor Cyan
Write-Host "  配置：$cfgUsed  (节点<=$maxNodeChars 字 / 每分支<=$maxChildren 子节点 / 层数<=$maxDepth)" -ForegroundColor DarkCyan
if ($cfgWarnings.Count -gt 0) {
    foreach ($w in $cfgWarnings) { Write-Host "  [配置警告] $w" -ForegroundColor Yellow }
}
Write-Host '------------------------------------------------------------'
$pass = 0
foreach ($r in $results) {
    if ($r.Ok) {
        Write-Host ("  [PASS] {0}. {1}  —— {2}" -f $r.Id, $r.Name, $r.Detail) -ForegroundColor Green
        $pass++
    } else {
        Write-Host ("  [FAIL] {0}. {1}  —— {2}" -f $r.Id, $r.Name, $r.Detail) -ForegroundColor Red
    }
}
Write-Host '------------------------------------------------------------'
$verdict = "$pass / $($results.Count) 通过"
if ($pass -eq $results.Count) {
    Write-Host "  结论：$verdict  —— 可进入导出阶段" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  结论：$verdict  —— 先修 FAIL 项，不得导出" -ForegroundColor Red
    exit 1
}
