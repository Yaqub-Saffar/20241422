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

### AI 使用声明

- `handmade/` 下所有内容：本人手工完成，未使用 AI 辅助。
- `skill/`、`output/generated.md`：由 AI 依据本人提供的学习内容与真实实践记录生成。
- `output/human-edited.md`：本人逐句审阅修改，修改处用 `[[ ]]` 标注修改原因。
- `feedback/`：本人书写的改进意见，AI 负责落实。
- 本文与 `handmade/reflection.md`：本人撰写，AI 仅提问引导，不代写。

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
│   │   └── changelog.md      本版设计思路与变更理由
│   └── v2 … v7/
├── output/                   各版 Skill 实际生成的作业
│   ├── v1/
│   │   ├── generated.md      AI 原始生成（未审阅）
│   │   └── human-edited.md   人工审阅修改后的最终版
│   └── v2 … v7/
├── feedback/                 每轮给 AI 的反馈记录
│   ├── v1-to-v2.md
│   └── …
├── report/
│   └── final-analysis.md     Phase 10 总结报告
├── assets/                   思维导图 PNG 等图片资源
├── tools/                    辅助脚本（导出、渲染、校验）
└── .opencode/skills/preview-report/SKILL.md   Skill 工作副本（供 opencode 加载）
```

> `skill/vN/SKILL.md` 是 Skill 的**唯一真源**；`.opencode/skills/preview-report/SKILL.md`
> 只是当前迭代版本的运行副本，用 `tools\use-version.ps1` 从真源同步，二者不应分别编辑。

---

## 三、运行方式

### 3.1 环境依赖

| 依赖 | 版本 | 用途 | 检查命令 |
| --- | --- | --- | --- |
| opencode | ≥ 1.18 | 运行 Skill 的智能体 | `opencode --version` |
| Node.js + npm | ≥ 18 | 运行 mermaid-cli | `node -v` |
| @mermaid-js/mermaid-cli | 12.x | Mermaid 思维导图 → PNG | `mmdc --version` |
| Pandoc | ≥ 3.x | Markdown → DOCX | `pandoc --version` |
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

### 3.4 导出报告（Markdown → 图片 + DOCX）

```powershell
# 渲染思维导图并导出 docx / pdf
powershell -ExecutionPolicy Bypass -File tools\export.ps1 -Report output\v1\human-edited.md
```

脚本会完成三件事：

1. 抽出 Markdown 中的 ```mermaid 代码块，逐个渲染为 `assets/*.png` 并回填图片引用
2. 调用 Pandoc 导出 DOCX
3. 调用 Pandoc 导出 HTML，再用本机 Edge 无头模式打印为 PDF

---

## 四、Git 标签对照

| 标签 | 含义 |
| --- | --- |
| `phase1-handmade` | 手工版作业完成 |
| `skill-v1` … `skill-v7` | 第 1 至第 7 版 Skill 定稿 |
| `final-report` | 总结报告完成 |

提交信息格式统一为 `[phase] 简短描述`，正文说明「修改了 Skill 的哪一部分、为什么改」。
