# 第 3 周 · 输入

> 本文件记录用户提供给 Skill 的原始输入，由用户本人提供，AI 未改写事实部分。

## 基本信息

- 周次：第 3 周
- 老师本周额外要求：无
- 提交格式：Markdown + PDF

## 学习内容

| 书 / 资料 | 章节 | 重点小节 | 这一节讲了什么 |
| --- | --- | --- | --- |
| Head First C 嗨翻 C 语言 | 第 4 章 | 全章 | 多源文件编译与链接原理、头文件与头文件保护、函数声明与定义分离、模块化设计思路、Makefile 自动化构建 |
| Windows C/C++ 加密解密实战 | 第 4 章 | 4.2、4.3、4.5 | 分组密码工作模式（ECB/CBC/CFB/OFB/CTR）、填充机制、密钥与 IV 的作用、OpenSSL 的 EVP 接口调用与返回值检查、编译链接选项 |
| 课程 mindmap | — | — | 网络空间安全框架、密码系统、法律法规与标准、密码应用与密评、gitee/github/OpenSSL/GmSSL 工具链 |

## 本周实际做了什么

- 编写多源文件 AES 加解密程序（`aes.h` / `aes.c` / `main.c` 分文件组织），实现加密与解密两个功能
- 在 Windows + MinGW (GCC) 环境下编译链接
- 排查链接期与运行期的两类报错

## 遇到的报错 / 问题

### 问题 1（多文件 AES 程序的链接与填充问题）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| `undefined reference to 'EVP_EncryptInit_ex'` | 编译能过（`-c` 阶段无报错），只有最终链接 exe 时报错 | 补上 `-lcrypto` 链接选项 |
| 输入明文长度不是 16 整倍数时加密结果异常 | 用 7 字节明文测试时输出长度不对 | 用 `EVP_CIPHER_CTX_set_padding` 处理，确认 EVP 默认启用 PKCS#7 填充，关闭填充后必须自行保证数据为块大小整数倍 |

### 问题 2（AI 工具链使用受阻）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| OpenCode 执行需要授权的命令时中断，提示 `Device approval failed`，依赖脚本被拦截 | 用 OpenCode 智能体尝试自动完成环境安装与导出脚本时 | 重新走设备码/浏览器授权登录流程，授权状态恢复后同一命令正常执行 |

**背景**：此前曾用 OpenCode 智能体尝试完成依赖安装与脚本自动化，遇到授权失败（`Device approval failed`）与依赖脚本被拦截两个问题。**用户确认：最终通过重新登录授权解决。**

## 想让 AI 帮上忙的地方

- 代写：AI 对学习内容的总结、思维导图节点整理
- 不代写：反思与补充、实践问题的解决过程

## 反思落点（用户本人选定）

用户从 Skill 提出的 5 个候选点中认可以下 2 条，并要求用第一人称写入报告：

1. **IV 复用的安全代价** —— 教材讲了各工作模式的流程，但没讲 CBC 的 IV 每次都必须不同、
   IV 复用会泄露明文前缀的相等关系
2. **第 4 章主题与第 3 章知识撞车** —— 声明/定义分离、链接顺序这些第 4 章的原理，
   正好解释了 `-lcrypto` 为什么会 `undefined reference`，但教材没把两者联系起来

## 本轮使用的 AI 工具

- [OpenCode](https://opencode.ai)：AI 编程智能体（CLI 端）
- [DeepSeek](https://chat.deepseek.com/)：内容总结

## 已核查的技术事实（阶段 1 websearch 确认，可直接引用）

- `EVP_CIPHER_CTX_set_padding(ctx, 0)` 关闭填充；必须在 `EVP_EncryptInit_ex()` 之后调用
- 填充默认开启，模式为 PKCS padding；补 n 个值为 n 的字节使总长为块大小整数倍
- 关闭填充后，`EVP_EncryptFinal_ex()` 不再处理尾部不足一整块的数据
- `EVP_EncryptInit_ex()` 的 `impl` 参数必须为 NULL
- `EVP_CIPHER_CTX_set_padding()` 恒返回 1
- `EVP_EncryptUpdate()` 对旧版密码要求输入长度为块大小整数倍
- `EVP_CIPHER_CTX` 自 OpenSSL 1.1.0 起为不透明类型
- `EVP_EncryptInit_ex()` 属 `libcrypto`，不在 `libssl` 中
- 链接顺序：目标文件在前，`-lcrypto` 在后
- OpenSSL 手册：https://docs.openssl.org/3.0/man3/EVP_EncryptInit

## 章节号核查（重要，防止误判学生）

用户说「Head First C 第 4 章 = 多源文件编译」与英文原版目录**不一致**
（英文版 Ch4 是 Functions，Ch5 才是 Compiling, Modifying, and Packaging），
核查时一度怀疑是用户报错章节号。结论：**用户是对的**——中文版《嗨翻 C 语言》沿用原版首版编号：

| 章 | 标题 | 说明 |
| --- | --- | --- |
| Ch 1 | Diving in | |
| Ch 2 | What are you Pointing at? | 内存与指针 |
| Ch 3 | Do one thing and do it well | |
| **Ch 4** | **Break it down, build it up** | **使用多个源文件 ← 本周** |
| Ch 7 | Turn your functions up to 11 | 高级函数 |
| Ch 8 | Hot-swappable code | 高级字符串与指针 ← 印证第二周报告的 Ch8 内容 |

来源：https://github.com/DaviNakamuraCardoso/c （Head First C 逐章学习笔记）

**复用价值**：中文版与英文版章节号不一致这件事，不查就会误判成"学生写错"。
以后遇到"章节号与公开资料对不上"，先查版本差异，再怀疑学生。
这条正是 v1 阶段 1「事实核查」存在的意义——没有它，这份报告会被我改错。
