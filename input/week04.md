# 第 4 周 · 输入

> 本文件记录用户提供给 Skill 的原始输入，由用户本人提供，AI 未改写事实部分。

## 基本信息

- 周次：第 4 周
- 老师本周额外要求：无
- 提交格式：Markdown + PDF

## 学习内容

| 书 / 资料 | 章节 | 重点小节 | 这一节讲了什么 |
| --- | --- | --- | --- |
| Head First C 嗨翻 C 语言 | 第 7 章 | 全章 | 数据结构与动态内存：用动态分配管理变长数据、malloc 与 free 必须配对、结构体指针、内存泄漏与重复释放；写入不定长的密钥、缓冲区时要用它 |
| Windows C/C++加密解密实战 | 第 5 章 | 5.2、5.3、5.5 | 非对称加密：RSA 与 ECC 的数学原理、密钥对生成、公钥加密私钥解密、OpenSSL 的 EVP_PKEY 抽象接口，以及 3.0 起的 provider 化变动 |
| 课程 mindmap | — | — | 公钥密码体制、密钥分发与管理、混合加密体系 |

## 本周实际做了什么

- 用 OpenSSL 3.x 的 EVP_PKEY 接口生成 2048 位 RSA 密钥对，导出为 PEM 文件
- 写 `rsa_demo.c`，把公钥加密、私钥解密串成一条完整流程
- 反复撞上"直接用 RSA 加密一段长明文会失败"，以及老教程里的 API 在新版本编译不过

## 遇到的报错 / 问题

### 问题 1（RSA 直接加密长明文失败）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| `EVP_PKEY_encrypt` 返回 0，错误栈里出现 `rsa_ossl.c` 与 `data too large for key size` | 先用一段 7 字节短明文测通，换成 200 多字节的明文时加密直接失败 | 查明 RSA 单次可加密长度受填充方式限制，改用混合加密：AES 加密数据、RSA 只加密会话密钥 |

### 问题 2（旧 API 在 OpenSSL 3.0 下被标记 deprecated）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| `warning: 'RSA_generate_key_ex' is deprecated: Since OpenSSL 3.0`，加 `-Werror` 后直接编译失败 | 照抄一份只适用于 1.1.1 的博客代码 | 查 3.0 migration guide，改用 `EVP_PKEY_CTX_new_id` + `EVP_PKEY_keygen` 系列接口 |

## 想让 AI 帮上忙的地方

- 代写：AI 对学习内容的总结、思维导图节点整理
- 不代写：反思与补充、实践问题的解决过程

## 反思落点（用户本人选定）

用户从 Skill 提出的 5 个候选点中认可以下 2 条，并要求用第一人称写入报告：

1. **RSA 有明文长度上限，真实系统必然是混合加密** —— 教材把对称加密和非对称加密分成两章讲，
   但实际使用中两者是配套的：非对称只用来传"密钥"，数据本身交给对称算法
2. **密钥对是"算"出来的不是"编"出来的** —— 教材给了"生成密钥对"的结论，
   但没讲生成时随机性的质量直接决定私钥能否被暴力破解

## 本轮使用的 AI 工具

- [OpenCode](https://opencode.ai)：AI 编程智能体（CLI 端）
- [DeepSeek](https://chat.deepseek.com/)：内容总结与报错分析

## 已核查的技术事实（阶段 1 websearch 确认，可直接引用）

- RSA 单次加密的最大明文长度：OAEP（SHA-256）下为 `k − 2·hLen − 2`，2048 位密钥（k=256 字节）即 256 − 64 − 2 = 190 字节；PKCS#1 v1.5 下为 `k − 11` = 245 字节
- `EVP_PKEY_encrypt()` 第一次以 `out = NULL` 调用会返回所需缓冲区长度（写入 `*outlen`）
- OpenSSL 3.0 起 `RSA_generate_key_ex` 等低层 API 被标记 deprecated，推荐 `EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, NULL)` + `EVP_PKEY_keygen_init()` + `EVP_PKEY_CTX_set_rsa_keygen_bits()` + `EVP_PKEY_keygen()`
- `EVP_PKEY_*` 属于 `libcrypto`，链接 `-lcrypto`
- OpenSSL migration guide：https://docs.openssl.org/3.0/man7/migration_guide
- OpenSSL EVP_PKEY_encrypt 手册：https://docs.openssl.org/3.0/man3/EVP_PKEY_encrypt
