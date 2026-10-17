# 第 5 周 · 输入

> 本文件记录用户提供给 Skill 的原始输入，由用户本人提供，AI 未改写事实部分。

## 基本信息

- 周次：第 5 周
- 老师本周额外要求：无
- 提交格式：Markdown + PDF

## 学习内容

| 书 / 资料 | 章节 | 重点小节 | 这一节讲了什么 |
| --- | --- | --- | --- |
| Head First C 嗨翻 C 语言 | 第 6 章 | 全章 | 结构体、联合与位字段：用结构体把相关字段打包、用 union 让多种类型共享同一块内存、用位字段压缩存储；处理定长报文头、摘要结构时用得上 |
| Windows C/C++加密解密实战 | 第 6 章 | 6.2、6.3、6.5 | 消息摘要算法：MD5、SHA-1、SHA-256、SM3 的原理与长度、EVP_Digest* 接口调用、摘要用于完整性校验、HMAC 做消息认证 |
| 课程 mindmap | — | — | 杂凑算法在密码系统中的地位、完整性保护与保密性的区别 |

## 本周实际做了什么

- 写 `digest.c`，对文件计算 SHA-256 与 SM3 摘要
- 用 Windows 自带的 `certutil -hashfile` 做对照
- 发现自己程序算出来的摘要和 `certutil` 对不上

## 遇到的报错 / 问题

### 问题 1（自己算的摘要与 certutil 不一致）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| 同一文件，`digest.c` 输出的 SHA-256 与 `certutil -hashfile sn.txt SHA256` 不同 | 想用 certutil 做交叉验证，两边结果却不一样 | 原因是 Windows 下 `fopen(path, "r")` 是文本模式，会把 `\r\n` 翻译成 `\n`；改成 `"rb"` 后两端一致 |

### 问题 2（摘要输出缓冲区开小了）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| 程序运行偶发崩溃、打印出乱码 | 抄了 MD5 示例的 `unsigned char md[16]`，只把算法换成 SHA-256 | SHA-256/SM3 摘要长度是 32 字节，写 32 字节进 16 字节缓冲越界；改用 `EVP_MD_size()` 取实际长度或 `EVP_MAX_MD_SIZE` |

## 想让 AI 帮上忙的地方

- 代写：AI 对学习内容的总结、思维导图节点整理
- 不代写：反思与补充、实践问题的解决过程

## 反思落点（用户本人选定）

用户从 Skill 提出的 5 个候选点中认可以下 2 条，并要求用第一人称写入报告：

1. **摘要是单向且无密钥的，只能验完整性不能验来源** —— 摘要谁都能算，所以它挡得住"传输损坏"，
   挡不住"被人改了再重算摘要"，要防篡改必须上 HMAC 或数字签名
2. **摘要算的是字节，不是"文件"** —— 换行、编码、文本/二进制模式的任何差异都会让摘要对不上，
   所以"摘要一致"这件事必须连同算法和输入字节一起说才成立

## 本轮使用的 AI 工具

- [OpenCode](https://opencode.ai)：AI 编程智能体（CLI 端）
- [DeepSeek](https://chat.deepseek.com/)：内容总结

## 已核查的技术事实（阶段 1 websearch 确认，可直接引用）

- 摘要长度：MD5 = 16 字节（128 位），SHA-1 = 20 字节（160 位），SHA-256 = 32 字节（256 位），SM3 = 32 字节（256 位）
- `EVP_MD_size(const EVP_MD *type)` 返回该摘要算法的输出字节数；`EVP_MAX_MD_SIZE` 是所有摘要算法中的最大输出长度
- `EVP_DigestInit_ex` / `EVP_DigestUpdate` / `EVP_DigestFinal_ex` 属于 `libcrypto`
- SM3 是国标 GB/T 32905-2016 定义的密码杂凑算法，输出 256 位
- OpenSSL 3.0 中 `EVP_sm3()` 需要算法提供者（provider）支持，`openssl list -digest-algorithms` 可查看
- OpenSSL EVP_DigestInit 手册：https://docs.openssl.org/3.0/man3/EVP_DigestInit
