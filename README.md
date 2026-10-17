# 预习作业 · AI Skill 迭代开发

《密码系统设计》课程预习报告的自动化 Skill 迭代项目。

- **学号 / 姓名**：20241422 穆弈涵
- **作业要求**：`AI_Skill_迭代开发`（选做，20 分）
- **迭代周期**：7 轮（v1 → v7），每轮产出一份真实周报作为测试样本
- **状态**：✅ 七轮全部完成，终版分析报告已产出（2026-10-17）；另用定稿 v7 **直接生成第 8~12 周预习报告**（2026-10-17）

---

## 一、作业阶段与本仓库对应关系

| 阶段 | 要求 | 分值 | 本仓库位置 | Git 标签 |
| --- | --- | --- | --- | --- |
| Phase 0 | 环境准备，建 Git 仓库与目录结构 | 1 | 仓库根目录 | — |
| Phase 1 | 手工完成第 1 次预习作业（禁用 AI） | 3 | `handmade/` | `phase1-handmade` |
| Phase 2 | 编写初始 Skill | 3 | `skill/v1/` | `skill-v1` |
| Phase 3-9 | 7 次迭代：生成 → 人工审阅 → 反馈改进 | 10 | `skill/v2..v7/`、`output/v1..v7/`、`feedback/` | `skill-v2` … `skill-v7` |
| Phase 10 | 总结报告 | 3 | `report/final-analysis.md` | `final-report` |

> **关于 Phase 1 的说明**
> 作业模板中 `handmade/homework1.md` 指「第一次由本人手工完成并提交给老师的预习作业」。
> 本仓库采用 **第二周预习报告** 作为 Phase 1 的手工版本（该次作业完全手写、无 AI 辅助，
> 并已实际提交给老师）。第一周报告未纳入本项目。

### 迭代进度（截至 2026-10-17，七轮全部完成）

要求是 7 轮（v1 → v7），每轮闭环为
**SKILL 定稿 → 实跑产出 → 人工审阅 → 反馈 → 改下一版**。

| 轮次 | SKILL | 实跑产物（周次） | 人工批注 | 反馈 | 标签 |
| --- | --- | --- | --- | --- | --- |
| v1 | ✅ | 第3周 | ✅ 7 处 | ✅ `v1-to-v2.md` | `skill-v1` `skill-v1-final` |
| v2 | ✅ | 第3周（复跑） | ✅ 4 处 | ✅ `v2-to-v3.md` | `skill-v2` `skill-v2-final` |
| v3 | ✅ | 第4周 | ✅ 5 处 | ✅ `v3-to-v4.md` | `skill-v3` `skill-v3-final` |
| v4 | ✅ | 第5周 | ✅ 4 处 | ✅ `v4-to-v5.md` | `skill-v4` `skill-v4-final` |
| v5 | ✅ | 第6周 | ✅ 4 处 | ✅ `v5-to-v6.md` | `skill-v5` `skill-v5-final` |
| v6 | ✅ | 第7周 | ✅ 4 处 | ✅ `v6-to-v7.md` | `skill-v6` `skill-v6-final` |
| v7 | ✅ | 第8周（泛化）+ 第3周（重跑基线） | ✅ 4 处 | ✅ `v7-to-final.md` | `skill-v7` `skill-v7-final` |
| 终版 | — | — | — | — | `final-report` |

> **v7 的泛化验证**：v1~v6 用的是第 3~7 周输入，v7 改用**从未参与调参**的
> `input/week08.md`（一周跨三份资料 + SM2/SM3/SM4 三个并列算法）走完整流程，
> `check-report.ps1 -Week 8` 全 PASS，**全程不改脚本**；并重跑第 3 周作 v1↔v7 对比基线。

### 各版本实际解决的问题（对应老师评分细则）

| 版本 | 本版解决什么 | 老师"重点考察" |
| --- | --- | --- |
| v2 | 阶段 1.5「定精度」+ 铁律 6（抽象名词落地） | 从手工经验抽象出有效 Skill |
| v3 | 阶段 3.5「锚点机制」+ 铁律 7/8（越界 / 断言条件） | 反馈是否具体、可执行 |
| v4 | `glossary.md` + 阶段 1.6「术语对齐」+ 铁律 9 | 处理教材特定概念 / 术语 |
| v5 | `tools/check-report.ps1`（机检 8 项）+ 铁律 10 | 引入自我检查 / 验证机制 |
| v6 | `report.config.yml` + 长章节组织 + 铁律 11 | 处理边界情况或复杂章节 |
| v7 | 版本号显式 + 配置校验 + 留出输入泛化实测 + 铁律 12 | 泛化能力或稳定性 |
| 终版 | `report/final-analysis.md`：变化曲线 + 进化逻辑 + v1 对比 | 与 v1 对比 |

> 评分细则原件见 `../AI_Skill_迭代开发.md` 第五节。**注意：`skill/v2/changelog.md`
> 末尾自列的「已知不足 → 计划版本」表与评分细则整体错位一格**，本仓库按评分细则执行。

### 定稿后批次：第 8~12 周（v7 直接生成，不再迭代）

v7 定稿后，用**同一版 v7 Skill**（不再改动）直接生成第 8~12 周预习报告：

| 周次 | 教材章节（Head First C） | 产物 |
| --- | --- | --- |
| 第8周 | 第12章 套接字与网络（另含《加密解密实战》第9、10章） | `output/v7/human-edited.md` |
| 第9周 | 第11章 进程间通信 | `output/v7/week09/` |
| 第10周 | 第13章 线程 | `output/v7/week10/` |
| 第11周 | 第8章 函数进阶 | `output/v7/week11/` |
| 第12周 | 第5章 使用多个源文件 + make | `output/v7/week12/` |

- 第 9~12 周各产出 `generated.md` + `self-review.md` + `generated.pdf`，`check-report.ps1` 均 **9/9 PASS**。
- 第 9~12 周「学习内容」本周只有 HFC 一章；「实践问题与解决」两题按**教材经典练习场景**撰写
  并在文内标注，**非本人实测记录**（本批次经本人授权直接生成、不逐周过目），
  相关的「我的补充」与两题的锚点见各自 `self-review.md`。
- 第 8~12 周提交件均已打包至 `submit\`。

### AI 使用声明

**本人手写、AI 未参与（本人真实判断）：**

- `handmade/homework1.md`：第二周预习报告全文，本人手工完成并已提交老师，未使用 AI 辅助。
- `handmade/reflection.md`：本人手写。
- `feedback/vN-to-vM.md`：本人审阅产物后书写的改进意见。
- `output/vN/human-edited.md` 中的 `[[修改原因]]` 批注：本人审阅后标注。
- 报告中的「对 AI 总结的反思与补充」一节：**观点由本人选定 / 口述，AI 仅负责成文**。
- 报告中的「实践问题与解决」一节：事实由本人提供，AI 未编造任何报错、步骤或环境。

**由 AI 生成或编写：**

- `skill/v1..v7/`：Skill 规约，由 AI 依据 `handmade/homework1.md` 的写作习惯反推编写。
- `output/v*/generated.md`：AI 生成的原始草稿。
- `tools/`：全部脚本由 AI 编写与调试（`export.ps1`、`use-version.ps1`、
  `package-submit.ps1`、`check-report.ps1`、`version.ps1`）。
- `input/weekNN.md` 中的「已核查的技术事实」小节：AI 联网核查的结果。
- **本文（README.md）：由 AI 编写**，仅结构与事实部分经本人确认。

**已知局限（主动说明）：**

- AI 无法读取微信读书 / ituring 的付费正文，因此 `output/v*/generated.md` 中
  「AI 对学习内容的总结」一节是根据本人提供的章节提要 + 公开资料（官方文档、目录等）
  写成的，**不保证与教材原文逐句一致**。本人已对照教材核对并修改。
- 「我的补充」与「经验总结」中的第一人称判断，均来自本人真实阅读与实践，不代写。
- **例外**：第 9~12 周为「定稿后直接生成」批次，经本人授权不逐周过目，故其中
  「实践问题与解决」两题按**教材经典练习场景**撰写并已在文内标注（非本人实测），
  「我的补充」为 AI 起草——上述不确定处均以 `<!-- 待确认 -->` 锚点标出，
  见 `output/v7/week09…week12/self-review.md`。

---

## 二、目录结构

```
预习作业-skill迭代/
├── README.md                 项目说明（本文件），含运行方式
├── report.config.yml         机检阈值配置（v6 新增，可配导图节点字数/分支数/层数）
├── handmade/                 Phase 1：纯手工作业
│   ├── homework1.md          第二周预习报告（手工版）
│   └── reflection.md         手写时的卡壳点与对 AI 的期望
├── skill/                    Skill 进化史，每版一个目录
│   ├── v1/ … v7/
│   │   ├── SKILL.md          Skill 本体（铁律 / 流程 / 引用）
│   │   ├── changelog.md      本版设计思路与变更理由
│   │   └── references/       按需加载细节：骨架 / 文风 / 精度 / 术语 / 自查 / 复杂章节 / 稳定性 …
│   └── v7/references/        共 10 个：structure, style, precision, review-anchors,
│                             glossary, standards, self-check, complex-chapter,
│                             stability, weekly-input-template
├── output/                   各版 Skill 实际生成的作业
│   ├── v1/ … v7/
│   │   ├── generated.md      AI 原始生成（未审阅）
│   │   ├── generated.pdf     导出产物（不入库，见 .gitignore）
│   │   ├── self-review.md    锚点清单（v3 起）
│   │   └── human-edited.md   人工审阅修改后的最终版 —— 这才是提交物
│   └── v7/week03-rerun.md    v7 复跑第3周，作 v1↔v7 对比基线
│   └── v7/week09 … week12/   定稿后批次：第 9~12 周（generated + self-review + pdf）
├── feedback/                 每轮给 AI 的反馈记录
│   └── v1-to-v2.md … v7-to-final.md
├── input/                    每周提供给 Skill 的原始输入（周次、章节、真实经历）
│   └── week03.md … week12.md
├── report/
│   └── final-analysis.md     Phase 10 总结报告
├── submit/                   待上传的提交件（学号 姓名 课程名 周次，md + pdf）
├── assets/                   思维导图 PNG 等图片资源（可重新导出）
├── tools/                    辅助脚本（导出、版本切换、机检、版本号、打包）
└── .opencode/skills/preview-report/SKILL.md   Skill 工作副本（供 opencode 加载）
```

> `skill/vN/SKILL.md` 是 Skill 的**唯一真源**；`.opencode/skills/preview-report/SKILL.md`
> 只是当前迭代版本的运行副本，用 `tools\use-version.ps1` 从真源同步，二者不应分别编辑。
>
> `input/` 与 `tools/`、`assets/`、`.opencode/` 是在老师要求的目录之外补充的：
> `input/` 用于留痕"这一轮我到底给了 AI 什么"，让迭代过程可核查。

---

## 三、运行方式

### 3.1 环境依赖

| 依赖 | 版本 | 用途 | 检查命令 |
| --- | --- | --- | --- |
| opencode | ≥ 1.18 | 运行 Skill 的智能体 | `opencode --version` |
| Node.js + npm | ≥ 18 | 运行 mermaid-cli | `node -v` |
| @mermaid-js/mermaid-cli | 12.x | Mermaid 思维导图 → PNG | `mmdc --version` |
| Pandoc | ≥ 3.x | Markdown → HTML（再由 Edge 打印 PDF） | `pandoc --version` |
| Git | ≥ 2.5 | 版本记录 | `git --version` |

### 3.2 使用 Skill 生成周报

1. 用 opencode 打开本仓库根目录
2. 直接说出触发语，例如：

   ```
   写第八周预习报告
   ```

   或显式调用：

   ```
   @preview-report 写第八周预习报告
   ```

3. Skill 会按流程执行：收集输入 → 事实核查 → **定精度（1.5）** → **术语对齐（1.6）** →
   起草（含长章节组织）→ 自查（**3A 机检 / 3B 人检**）→ **标薄弱点（3.5）** → 导出
4. 产出的草稿位于 `output/vN/generated.md`，**必须人工审阅后**另存为
   `output/vN/human-edited.md` 并标注修改原因

5. 版本号由 `tools/version.ps1` 显式解析（命令行 `-Version` → 输入 front-matter → 推断）：

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\version.ps1 -Input input\week08.md
   ```

### 3.3 切换 Skill 版本

```powershell
# 把 skill/vN 同步为当前运行版本
powershell -ExecutionPolicy Bypass -File tools\use-version.ps1 -Version 7
```

### 3.4 机检（导出前的硬关卡）

```powershell
# 对草稿跑 9 项结构性检查；全部 PASS 才导出
powershell -ExecutionPolicy Bypass -File tools\check-report.ps1 -Report output\v7\generated.md -Week 8
# 检查终稿：第 7 项改为断言"锚点已全部解除"
powershell -ExecutionPolicy Bypass -File tools\check-report.ps1 -Report output\v7\human-edited.md -Week 8 -Final
```

脚本读取 `report.config.yml` 里的阈值；配置写坏（非法值 / 未知键）会打印 `[配置警告]` 并回退默认。

> `tools/*.ps1` 为 PowerShell 脚本，**PowerShell 5.1 要求 UTF-8 BOM**，否则中文会被当 GBK 解析报错。

### 3.5 导出报告（Markdown → 思维导图 PNG + PDF）

```powershell
powershell -ExecutionPolicy Bypass -File tools\export.ps1 -Report output\v7\human-edited.md
```

脚本会完成两件事：

1. 抽出 Markdown 中的 ```mermaid 代码块，逐个渲染为 `assets/*.png` 并回填图片引用
2. 调用 Pandoc 导出单文件 HTML（CSS 内嵌），再用本机 Edge 无头模式打印为 PDF

> **DOCX 默认不生成。** 老师只收 Markdown 与 PDF，多一种格式只是多一份可能在提交前
> 忘更新的副本。确实需要时加 `-Docx`。`*.pdf` 与 `*.docx` 均在 `.gitignore` 中
> （`submit/*.pdf` 例外，会被提交）。

### 3.6 打包提交件

```powershell
# 生成 submit\20241422 穆弈涵 《密码系统设计》第八周.md / .pdf
powershell -ExecutionPolicy Bypass -File tools\package-submit.ps1 -Report output\v7\human-edited.md -Week 8 -Desktop
```

`submit\` 里按周存放（**MD 与 PDF 都带周次**，避免多周互相覆盖）。

---

## 四、Git 标签对照

| 标签 | 含义 |
| --- | --- |
| `phase1-handmade` | 手工版作业完成 |
| `skill-v1` … `skill-v7` | 第 N 版 Skill **定稿**（只有 SKILL.md，不含产物） |
| `skill-v1-final` … `skill-v7-final` | 某版 Skill 的**完整交付物**（含报告与工具修复） |
| `final-report` | 总结报告完成 |

> 为什么每版有两个标签：`skill-vN` 打在 Skill 定稿那次提交上，
> 但那时报告还没产出、工具脚本还可能有 bug——老师按该标签看不到实际交付状态。
> `skill-vN-final` 指向该版真正可以交付的提交。
>
> **`git push` 不会自动推 tag**，每轮打完 `skill-vN` / `skill-vN-final` 需单独
> `git push origin <tag名>`，否则老师点开 GitHub 的 tag 列表是空的。

分支：`experiment/strict-config`（加分项）——把机检的 `-StrictConfig` 变体（配置警告升级为硬失败）
放在独立分支上做对照实验，`report/final-analysis.md` 第四节记录了实验结论。

提交信息格式统一为 `[phase] 简短描述`，正文说明「修改了 Skill 的哪一部分、为什么改」。

**写提交信息的两个坑**（都踩过）：

- 正文里不要出现英文双引号。PowerShell 传给原生程序时会截断参数，
  导致 `git commit` 把正文里的 `-V`、`--metadata` 之类当成 git 自己的选项而报错。
- 不要用反引号（PowerShell 的转义符），会破坏参数边界。

长正文用单引号 here-string（`@'...'@`）最稳。
