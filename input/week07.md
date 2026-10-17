# 第 7 周 · 输入

> 本文件记录用户提供给 Skill 的原始输入，由用户本人提供，AI 未改写事实部分。

## 基本信息

- 周次：第 7 周
- 老师本周额外要求：无
- 提交格式：Markdown + PDF

## 学习内容

| 书 / 资料 | 章节 | 重点小节 | 这一节讲了什么 |
| --- | --- | --- | --- |
| Head First C 嗨翻 C 语言 | 第 10 章 | 全章 | 进程与系统调用：程序如何创建进程、文件描述符在进程间的意义、程序与操作系统的交互边界；理解程序运行时依赖哪些系统资源 |
| Windows C/C++加密解密实战 | 第 8 章 | 8.2、8.4、8.6 | SSL/TLS 安全通信：握手过程与会话密钥协商、证书验证、SSL_CTX 与 SSL 对象的编程模型、前向保密 |
| 课程 mindmap | — | — | 安全通信协议栈、TLS 在应用层与传输层之间的位置 |

## 本周实际做了什么

- 写了一个最小 TLS 客户端，连一个公网站点读它的证书
- 用抓包看 ClientHello / ServerHello 的交换
- 连接过程中证书验证失败；后来验证通了，却发现主机名不匹配没被拦下来

## 遇到的报错 / 问题

### 问题 1（`SSL_connect` 报证书验证失败）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| `SSL_connect` 返回 ≤ 0，`SSL_get_error` 指向证书验证失败 | 用 `TLS_client_method` 建连接，握手没走通 | 没有给 `SSL_CTX` 加载根证书；补 `SSL_CTX_set_default_verify_paths` 并显式 `SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL)` 后成功 |

### 问题 2（证书链有效但主机名不匹配未被拦截）

| 报错原文 / 现象 | 怎么发现的 | 最后怎么解决的 |
| --- | --- | --- |
| 拿一个证书域名与实际访问域名不符的站点测试，连接居然成功 | 出于好奇做的越界测试 | 证书链验证只校签发关系，主机名要另用 `SSL_set1_host`/`X509_check_host` 校验；加上后正确拦截 |

## 想让 AI 帮上忙的地方

- 代写：AI 对学习内容的总结、思维导图节点整理
- 不代写：反思与补充、实践问题的解决过程

## 反思落点（用户本人选定）

用户从 Skill 提出的 5 个候选点中认可以下 2 条，并要求用第一人称写入报告：

1. **TLS 的保密性和认证性是两回事** —— 会话密钥协商成功只保证通道加密，
   不校验证书就等于在跟中间人"安全地"通信，验证必须显式开启且校验主机名
2. **前向保密是有条件的** —— 只有用 ECDHE 这类临时密钥交换才有前向保密；
   用 RSA 静态密钥交换的旧套件，长期私钥一旦泄露，历史流量可被解密

## 本轮使用的 AI 工具

- [OpenCode](https://opencode.ai)：AI 编程智能体（CLI 端）
- [DeepSeek](https://chat.deepseek.com/)：内容总结与报错分析

## 已核查的技术事实（阶段 1 websearch 确认，可直接引用）

- OpenSSL 默认**不**加载系统根证书，需调用 `SSL_CTX_set_default_verify_paths()`
- 默认**不**校验对端证书，需显式 `SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL)`
- 证书链验证与主机名校验是两件事：主机名需 `SSL_set1_host(ssl, hostname)` 或 `X509_check_host()`
- 前向保密（PFS）依赖临时（ephemeral）密钥交换，如 ECDHE；RSA 静态密钥交换不具备前向保密
- `SSL_connect` 的返回值：1 成功，0 握手被对端关闭，< 0 出错，需配合 `SSL_get_error` 判断
- OpenSSL SSL_CTX_set_verify 手册：https://docs.openssl.org/3.0/man3/SSL_CTX_set_verify
