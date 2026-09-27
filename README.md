# 预习作业 · AI Skill 迭代开发

《密码系统设计》课程预习报告的自动化 Skill 迭代项目。

- **学号 / 姓名**：20241422 穆弈涵
- **作业要求**：`AI_Skill_迭代开发`（选做，20 分）
- **迭代周期**：7 轮（v1 → v7），每轮产出一份真实周报作为测试样本

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

### 迭代进度（截至 2026-09-27）

要求是 7 轮（v1 → v7），每轮闭环为
**SKILL 定稿 → 实跑产出 → 人工审阅 → 反馈 → 改下一版**。

| 轮次 | SKILL | 实跑产物 | 人工批注 | 反馈 | 标签 |
| --- | --- | --- | --- | --- | --- |
| v1 | ✅ | ✅ | ✅ 7 处 | ✅ `v1-to-v2.md` | `skill-v1` `skill-v1-final` |
| **v2** | ✅ | ✅ 7/7 检查点通过 | ❌ **待本人审阅** | ❌ **待本人写** | `skill-v2` `skill-v2-final` |
| v3 | 仅 `references/standards.md` | — | — | — | — |
| v4 – v7 | — | — | — | — | — |

> **v2 的 7 项检查点全部通过**：v1 需人工修改的 7 处（并列模式被打包、PKCS#7 只给标准名、
> EVP 只写分工、IV 泄露范围笼统、对比对象悬空、漏「返回错误」、结论停在现象），
> v2 一次生成即写对，无需人工改动。判定依据见 `feedback/v1-to-v2.md` 第五节。
>
> **下一步不是写 v3**，而是先由本人审阅 `output/v2/generated.md`，
> 产出 `output/v2/human-edited.md`（每处改动标 `[[修改原因]]`）与 `feedback/v2-to-v3.md`。
> 跳过这两步，v3 就失去「依据真实反馈迭代」的依据。

### 各版本计划解决的问题

来自 `skill/v2/changelog.md` 末尾的「已知不足」表：

| 版本 | 要解决的不足 | 性质 |
| --- | --- | --- |
| v3 | 无教材术语表，同一概念不同周用词可能不一致 | 内容一致性 |
| v4 | 12 条自查全靠自觉，没有脚本化校验 | 自查自动化 |
| v5 | 思维导图节点数与字数限制硬编码，复杂章节不够用 | 参数可配置 |
| v6 | 版本号 N 靠推断 `output/` 目录，手动改动会错 | 显式声明 |
| v7 | 无 v1 ↔ 终版的质量对比数据 | 收敛 + 量化对比 |

### AI 使用声明

**本人手写、AI 未参与：**

- `handmade/homework1.md`：第二周预习报告全文，本人手工完成并已提交老师，未使用 AI 辅助。
- `handmade/reflection.md`：本人手写。
- `feedback/vN-to-vN+1.md`：本人书写的改进意见。
- 报告中的「对 AI 总结的反思与补充」一节：**观点由本人口述/勾选，AI 仅负责成文**。
- 报告中的「实践问题与解决」一节：事实由本人提供，AI 未编造任何报错、步骤或环境。

**由 AI 生成或编写：**

- `skill/v1..v7/`：Skill 规约，由 AI 依据 `handmade/homework1.md` 的写作习惯反推编写。
- `output/v*/generated.md`：AI 生成的原始草稿。
- `tools/`：全部脚本由 AI 编写与调试。
- `input/v*.md` 中的「已核查的技术事实」小节：AI 联网核查的结果。
- **本文（README.md）：由 AI 编写**，仅结构与事实部分经本人确认。

**已知局限（主动说明）：**

- AI 无法读取微信读书 / ituring 的付费正文，因此 `output/v*/generated.md` 中
  「AI 对学习内容的总结」一节是根据本人提供的章节提要 + 公开资料（官方文档、目录等）
  写成的，**不保证与教材原文逐句一致**。本人已对照教材核对并修改。
- 「我的补充」与「经验总结」中的第一人称判断，均来自本人真实阅读与实践，不代写。

---

## 二、目录结构

```
预习作业-skill迭代/
├── README.md                 项目说明（本文件），含运行方式
├── handmade/                 Phase 1：纯手工作业
│   ├── homework1.md          第二周预习报告（手工版）
│   └── reflection.md         手写时的卡壳点与对 AI 的期望
├── skill/                    Skill 进化史，每版一个目录
│   ├── v1/
│   │   ├── SKILL.md          Skill 本体（Prompt / 规则 / 引用）
│   │   ├── changelog.md      本版设计思路与变更理由
│   │   └── references/       按需加载的细节：骨架 / 文风 / 输入模板
│   ├── v2/
│   │   ├── SKILL.md          新增阶段 1.5 定精度、铁律 6
│   │   ├── changelog.md
│   │   └── references/       多了 precision.md（精度标准）
│   └── v3 … v7/                                                 [待建]
├── output/                   各版 Skill 实际生成的作业
│   ├── v1/
│   │   ├── generated.md      AI 原始生成（未审阅）
│   │   ├── generated.pdf     导出产物（不入库，见 .gitignore）
│   │   └── human-edited.md   人工审阅修改后的最终版 —— 这才是提交物
│   ├── v2/
│   │   ├── generated.md      AI 原始生成，7 项检查点一次通过
│   │   └── human-edited.md   人工审阅修改后的最终版                      [待写]
│   └── v3 … v7/                                                 [待建]
├── feedback/                 每轮给 AI 的反馈记录
│   ├── v1-to-v2.md           来自 v1 产物的 7 处人工批注
│   └── v2-to-v3.md                                             [待写]
├── input/                    每周提供给 Skill 的原始输入（周次、章节、真实经历）
│   └── week03.md
├── report/
│   └── final-analysis.md     Phase 10 总结报告                    [待写]
├── assets/                   思维导图 PNG 等图片资源
├── tools/                    辅助脚本（导出、渲染、版本切换）
└── .opencode/skills/preview-report/SKILL.md   Skill 工作副本（供 opencode 加载）
```

> 标 `[待写]` / `[待建]` 的文件尚未创建，其余均已入库。
>
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
   写第三周预习报告
   ```

   或显式调用：

   ```
   @preview-report 写第三周预习报告
   ```

3. Skill 会按五阶段流程执行：收集输入 → 资料核查 → 起草 → 自查 → 导出
4. 产出的草稿位于 `output/vN/generated.md`，**必须人工审阅后**另存为
   `output/vN/human-edited.md` 并标注修改原因

### 3.3 切换 Skill 版本

```powershell
# 把 skill/vN 同步为当前运行版本
powershell -ExecutionPolicy Bypass -File tools\use-version.ps1 -Version 3
```

### 3.4 导出报告（Markdown → 思维导图 PNG + PDF）

```powershell
# 渲染思维导图并导出 pdf
powershell -ExecutionPolicy Bypass -File tools\export.ps1 -Report output\v1\human-edited.md
```

脚本会完成两件事：

1. 抽出 Markdown 中的 ```mermaid 代码块，逐个渲染为 `assets/*.png` 并回填图片引用
2. 调用 Pandoc 导出单文件 HTML（CSS 内嵌），再用本机 Edge 无头模式打印为 PDF

> **DOCX 默认不生成。** 老师只收 Markdown 与 PDF，多一种格式只是多一份可能在提交前
> 忘更新的副本。确实需要时加 `-Docx`：
>
> ```powershell
> powershell -ExecutionPolicy Bypass -File tools\export.ps1 -Report output\v1\human-edited.md -Docx
> ```
>
> `*.docx` 与 `*.pdf` 都已在 `.gitignore` 中——它们是可重新导出的产物，
> 仓库只提交 Markdown 源文件与思维导图 PNG。

---

## 四、Git 标签对照

| 标签 | 含义 |
| --- | --- |
| `phase1-handmade` | 手工版作业完成 |
| `skill-v1` … `skill-v7` | 第 N 版 Skill **定稿**（只有 SKILL.md，不含产物） |
| `skill-v1-final` … | 某版 Skill 的**完整交付物**（含报告与工具修复） |
| `final-report` | 总结报告完成 |

> 为什么每版有两个标签：`skill-vN` 打在 Skill 定稿那次提交上，
> 但那时报告还没产出、工具脚本还可能有 bug——老师按该标签看不到实际交付状态。
> `skill-vN-final` 指向该版真正可以交付的提交。

提交信息格式统一为 `[phase] 简短描述`，正文说明「修改了 Skill 的哪一部分、为什么改」。

**写提交信息的两个坑**（都踩过）：

- 正文里不要出现英文双引号。PowerShell 传给原生程序时会截断参数，
  导致 `git commit` 把正文里的 `-V`、`--metadata` 之类当成 git 自己的选项而报错。
- 不要用反引号（PowerShell 的转义符），会破坏参数边界。

长正文用单引号 here-string（`@'...'@`）最稳。
