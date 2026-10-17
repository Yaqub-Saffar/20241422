# v6 → v7 反馈

> 来源：`output/v6/human-edited.md` 的 4 处人工批注 + 对 v6 的验证结论。
> 这份文件记录的是**我审阅 v6 产物时发现的问题**，v7 按此修改。

## 一、先验证：v6 的配置机制真的生效了没有

| 测试 | 命令 | 结果 |
| --- | --- | --- |
| 合格稿（默认配置） | `-Report output\v6\generated.md -Week 7` | **9 / 9 PASS** |
| 回归（v4 旧稿） | `-Report output\v4\generated.md -Week 5` | **9 / 9 PASS** |
| 回归（v5 旧稿） | `-Report output\v5\generated.md -Week 6` | **9 / 9 PASS** |
| **收紧阈值** | `-Config` 指向 `max_node_chars: 4 / max_children: 2 / max_depth: 3` | **[4] 与 [9] 变 FAIL，且逐项列出超长节点与超限分支** |

**结论：v6 的"阈值可配"是真的。** 同样的稿子，改配置就能改变判定——
证明第 4、9 项读的是 `report.config.yml`，不是写死的常量。
`human-edited.md` 里**结构性改动为 0**，复杂章节的分组/分层也按 `complex-chapter.md` 落地了。

## 二、但一测配置的"坏输入"，就露馅了：**配置没有校验**

上面都是"好配置"，我一试坏配置，立刻出问题：

| 坏输入 | 实际行为 | 问题 |
| --- | --- | --- |
| `max_node_chars: abc`（非数字） | 被解析成 **0**（`[int]::TryParse` 失败时把引用置 0） | 所有节点瞬间"超长"，脚本报一堆 FAIL——**但根源是配置写坏了，不是稿子坏了** |
| `max_childern: 2`（key 拼错） | **静默忽略** | 拼错的键既不生效、也不报警，人以为设了、其实没设 |

一句话：**配置成了新的"软肋"——写坏了不报错，还朝错误的方向跑。**
v5 的教训是"自查靠自觉会漏"，v6 别让配置也变成"靠自觉"。

## 三、还有两个更早就欠着的问题

1. **版本号 N 仍靠推断 `output/` 目录**。SKILL 阶段 0 写的是"取 `output/` 下最大版本号 +1"。
   只要目录被手动改动（删了 v3、或建了个临时 `output/test`），N 就会算错，报告标题、
   根节点、输出路径全跟着错。这是**稳定性**问题：同一个 Skill，换个目录状态就产出不同结果。
2. **从未在"没见过的输入"上验证过泛化**。v1~v6 用的都是 week03~07，
   输入风格高度相似。**没有证据**说明换一种输入（没做过的章节、含国密的章节）还能跑通。

## 四、v7 要改什么（具体、可执行）

| # | 改动 | 位置 | 对应 |
| --- | --- | --- | --- |
| 1 | **版本号显式声明**：优先读命令行 `-Version` 或输入文件 front-matter 的 `report_version:`，都不给才回退到"推断 `output/`"，并**打印实际取值** | `SKILL.md` 阶段 0 + 新增 `tools/version.ps1` | 第三节 1 |
| 2 | **`check-report.ps1` 增加配置校验**：未知 key（如 `max_childern`）报警；非法值（非数字/越界）**报错并回退默认**，不再静默成 0 | `tools/check-report.ps1` | 第二节 |
| 3 | **泛化验证**：用 `input/week08.md`（套接字 + PKI + 国密 SM2/SM3/SM4）跑 v7，**不改任何脚本**，验证仍能产出合规报告 | `output/v7/` | 第三节 2 |
| 4 | **重跑 v1 的输入**（week03）产出 `output/v7/week03-rerun.md`，作为 v1↔v7 对比的基线 | `output/v7/` | 终版对比 |
| 5 | `SKILL.md` 新增铁律 12「配置与版本号必须显式、可校验」 | `SKILL.md` | — |

### 版本号显式的取值优先级（草案）

```
① 命令行 -Version 2  → 最优先
② input/weekNN.md 的 front-matter: report_version: 3
③ 都没有 → 回退推断 output/ 下最大版本号 +1，并打印"推断得到 N，请确认"
```

## 五、怎么验证 v7 真的改进了

1. **泛化**：`-Report input\week08.md` 走完生成流程，`check-report.ps1 -Week 8` 应全 PASS；
   全程**不改一行脚本/SKILL**。
2. **配置校验**：拿 `max_node_chars: abc` 与 `max_childern: 2` 两个坏配置，
   脚本应**报错/报警**，不再静默成 0、不再无视拼错的键。
3. **版本号**：显式传入 7，报告标题与根节点应为「第七周」；不传时打印推断值供确认。
4. **对比基线**：`output/v7/week03-rerun.md` 与 `output/v1/human-edited.md` 摆一起，
   在 `report/final-analysis.md` 里量化差异。

**判定：坏配置能被拦下、换新输入不改脚本也能跑通、版本号可显式指定，则 v7 有效。**

## 六、留给最后（终版报告）

| 要做的 | 在哪 |
| --- | --- |
| v1↔v7 质量对比曲线、进化逻辑、个人收获 | `report/final-analysis.md` |
| 打包第 4~7 周提交件 | `submit/` |
