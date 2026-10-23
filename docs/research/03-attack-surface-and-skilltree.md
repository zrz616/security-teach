# 03 · 攻击面测绘 + 资产安全：技能树、工具地图与认证路径

> 面向对象：有开发经验、安全零基础的开发者；每周可投入 10–15h；目标是产出**工具/API 产品**与**教学/课程产品**，技术栈 TS 应用 + Python 工具。
>
> 本文所有「事实性声明」（工具现状、免费额度、认证结构、考试要求）都带**一手来源**行内链接（项目官方仓库 / 官方文档 / 认证官方页面）。凡现场核实不到的一律标 `[未核实]`。
>
> **核实时间：2026-10-13。** 版本号、价格、免费额度、考试版本都会变；本文把「核实日期」写进正文，而不是写成永恒事实。
> 核实方法说明：官方站点若对 curl 返回 403（Cloudflare 反爬，如 `comptia.org`、`centri.org`）或纯 SPA 空壳（如 `quake.360.net`），本文会显式标注；此时要么改用同域的官方文档页/官方 PDF，要么标 `[未核实]`，**不拿二手博客顶上**。

---

## 0. 这份文档回答什么

要做「传统网络安全 + 企业数据资产安全」，技能树不是一棵，而是**三棵树的并集**：

| 树 | 一句话 | 对本项目的产出形态 |
|---|---|---|
| **A. 攻击面测绘（ASM）** | 把「我暴露了什么」变成一份可持续更新的清单 | 工具/API 产品的主战场；也是课程里最容易被验证的教学内容 |
| **B. 漏洞验证与优先级** | 把「暴露了」变成「真的能被打，且值不值得先修」 | 产品差异化点（误报治理）；课程里最难讲但最值钱的一节 |
| **C. 检测与蓝队（防御侧）** | 把「被打了」变成「看得见、查得到、复现得了」 | 企业数据资产安全的落点；教学产品里最容易做成实验课的模块 |

三棵树共用同一个**基础层**（§1）。本文按「基础层 → A → B → C → 靶场 → 认证 → 知识清单」组织，并在每节给出**可检验的"够用"标准**。

**阅读方式建议**：§1 用来自查基础漏洞；§2 的表格当采购/选型清单用；§6 认证那节先看「性价比排序」结论再看细节。

---

## 1. 基础层：学到什么程度算够用

基础层的判断标准不是「看过多少书」，而是**能不能在没有任何 GUI、没有任何商业工具的前提下，独立复现一次观察到的问题**。下面每项给三档（读/用/工程）+ 检验方式。

### 1.1 TCP/IP 与抓包

- 规范一手来源：TCP 现在是 **RFC 9293（STD 7，2022-08，废弃 RFC 793 等）** — <https://www.rfc-editor.org/rfc/rfc9293>；HTTP 语义/1.1 分别是 **RFC 9110（STD 97）** <https://www.rfc-editor.org/rfc/rfc9110> 与 **RFC 9112（STD 99）** <https://www.rfc-editor.org/rfc/rfc9112>。
- 抓包工具：**Wireshark** 稳定版 **4.6.9**（另一条维护线 4.4.19），下载页 <https://www.wireshark.org/download.html>；仓库已迁到 GitLab <https://gitlab.com/wireshark/wireshark>；显示过滤器速查 <https://www.wireshark.org/docs/dfref/>。**tcpdump 4.99.7 + libpcap**，官网 <https://www.tcpdump.org/>，抓包表达式语法官方手册 <https://www.tcpdump.org/manpages/pcap-filter.7.html>。

**够用标准（可检验）**

| 档 | 可检验的验收动作 |
|---|---|
| 读 | 能解释三次握手中 SYN/SYN-ACK 的 `seq/ack` 关系，以及为什么「抓到 SYN 但没 SYN-ACK」和「抓到 SYN-ACK 但没有 ACK」是不同的故障（前者对端没监听/被过滤，后者中间有设备吞包）。 |
| 用 | 无 GUI 环境下完成：`tcpdump -i any -nn -s0 -w cap.pcap 'host X and port 443'`，再用 `tshark` 导出该连接的 TLS ClientHello 里 SNI 与支持版本；能手写 BPF 过滤（`tcp[tcpflags] & tcp-syn != 0`）。 |
| 工程 | 能自己写解析脚本：把 pcap 里的 TCP 流重组后取出 HTTP 请求行 + Host 头，统计出「本机在 1 小时内对外连了哪些域名的 443」——这就是一个小型资产发现器。**这一步做完，才算摸到"测绘"的门。** |

### 1.2 DNS / HTTP / TLS 细节

一手来源全覆盖（都是 IETF 正式规范，页面即原文）：

| 主题 | 规范 | 链接 |
|---|---|---|
| TLS 1.3 | RFC 8446（2018-08，废弃 5077/5246/6961） | <https://www.rfc-editor.org/rfc/rfc8446> |
| SNI（`server_name` 扩展） | RFC 6066（2011-01） | <https://www.rfc-editor.org/rfc/rfc6066> |
| HSTS | RFC 6797（2012-11） | <https://www.rfc-editor.org/rfc/rfc6797> |
| X.509 证书与路径校验 | RFC 5280（2008-05） | <https://www.rfc-editor.org/rfc/rfc5280> |
| 证书透明（CT） | RFC 6962（2013）已由 **RFC 9162（CT v2.0，2021-12）** 废弃 | <https://www.rfc-editor.org/rfc/rfc9162> |
| CAA 记录 | RFC 8659（2019-11，废弃 6844） | <https://www.rfc-editor.org/rfc/rfc8659> |
| ACME（Let's Encrypt 协议） | RFC 8555（2019-03） | <https://www.rfc-editor.org/rfc/rfc8555> |
| DoH | RFC 8484（2018-10） | <https://www.rfc-editor.org/rfc/rfc8484> |
| DNSSEC 引言/要求 | RFC 4033 | <https://www.rfc-editor.org/rfc/rfc4033> |
| RDAP（WHOIS 的替代） | IETF **STD 95**：RFC 7480 / 9082 / 9083 / 9224 | <https://www.rfc-editor.org/info/std95> |

**够用标准（可检验）**

| 档 | 可检验的验收动作 |
|---|---|
| 读 | 能解释：为什么「证书有效」≠「域名匹配」≠「链可信」（RFC 5280 里三条是不同检查）；HSTS 的 `max-age` 与 `includeSubDomains` 各自防什么攻击；CT 日志为什么能让「误签发」被发现（RFC 9162 的设计意图）。 |
| 用 | 用 `openssl s_client -connect host:443 -servername host -showcerts` 手工验证一条链，指出是哪一级签发的、`notAfter` 是哪天、SAN 里有哪些域名；能说出 SNI 在 TLS 1.3 里被 EncryptedExtensions 影响后，**为什么被动抓包仍能拿到 SNI**（除非 ECH）。 |
| 工程 | 写一个脚本，输入一批域名 → 输出「证书签发者 / notAfter / SAN 列表 / 是否已被 CT 记录 / 是否有 CAA 记录」的表格。**这张表就是「资产测绘」的第一张资产表**（域名 + 证书 + 到期时间本来就是同一批数据）。 |

> 资产测绘视角的一句话：**证书是互联网上最便宜的资产情报**——它免费、公开、带域名、带到期时间、带签发者，还带 CT 历史。§2 里 tlsx / crt.sh / CertStream 之所以重要，全部源于这一条。

### 1.3 Linux 系统与日志

- 审计子系统：上游仓库 <https://github.com/linux-audit/audit-userspace>（**GPL-2.0**，COPYING 为 GNU GPL v2）。
- 日志：systemd journald 官方手册 <https://www.freedesktop.org/software/systemd/man/latest/systemd-journald.service.html>；systemd 项目站 <https://systemd.io/>。
- 内核可观测：eBPF 官方门户 <https://ebpf.io/>。生产级可观测/运行时安全：**Falco**（<https://falco.org/>，仓库 <https://github.com/falcosecurity/falco>，**Apache-2.0**，CNCF 项目）与 **osquery**（<https://osquery.io/>，仓库 <https://github.com/osquery/osquery>，双许可 **Apache-2.0 OR GPL-2.0-only**，见其 `LICENSE`）。

**够用标准（可检验）**

| 档 | 可检验的验收动作 |
|---|---|
| 读 | 能说出 `ps`/`/proc`/`auditd`/eBPF 四种观测手段各自看得到什么、看不到什么（尤其：**能改 rootkit 的攻击者可以骗过 `/proc`，但骗不过 eBPF 的内核侧 kprobe**）。 |
| 用 | 用 auditd 规则抓到一次「进程执行 + 网络连接」，并从 `journalctl -o json` 里取出结构化字段（`_PID`/`_COMM`/`_EXE`），做出「谁在什么时候执行了什么」的时间线。 |
| 工程 | 写一个采集器：把 auditd/eBPF 事件规范化为统一 schema（`timestamp, host, pid, exe, cmdline, uid, dst_ip, dst_port`）落库；再证明**用一次已知的原子测试（§4 的 Atomic Red Team）能在你的数据里查到对应痕迹**。这是蓝队产品的第一个真实闭环。 |

### 1.4 云基础：AWS / Azure 安全模型差异

一手来源：

- 责任共担模型：AWS <https://aws.amazon.com/compliance/shared-responsibility-model/>；Azure <https://learn.microsoft.com/en-us/azure/security/fundamentals/shared-responsibility>。
- 权限模型：AWS IAM 策略求值逻辑 <https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html>；Azure RBAC 概览 <https://learn.microsoft.com/en-us/azure/role-based-access-control/overview>；Azure 身份平台 OAuth2 授权码流 <https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow>。
- 基线/基准：AWS Well-Architected 安全支柱 <https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html>；**Microsoft cloud security benchmark v2（官方标注 preview）** <https://learn.microsoft.com/en-us/security/benchmark/azure/overview>；CIS Benchmarks <https://www.cisecurity.org/cis-benchmarks>。
- 零信任参考架构：NIST SP 800-207 <https://csrc.nist.gov/pubs/sp/800/207/final>；控制基线 SP 800-53 Rev.5 <https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final>；NIST CSF <https://www.nist.gov/cyberframework>。

**两个云的关键差异（做产品必须知道，不然会写出只对一家成立的检测逻辑）**

| 维度 | AWS | Azure |
|---|---|---|
| 权限主体与作用域 | IAM policy 绑定到 user/role/group/resource，**显式 Deny 优先**，另有 SCP 在 OU 层设上限 | RBAC 的 role assignment 绑在 管理组/订阅/资源组/资源 的作用域上，**沿层级继承**；另有 Azure Policy 做治理约束 |
| 身份 | IAM 用户 + STS 临时凭证 + 实例/任务角色 | **Entra ID（原 Azure AD）是身份中心**，RBAC 与 Entra 目录角色是两套不同东西 |
| 「谁是管理员」 | root/account 用户 + IAM 全权策略 | 全局管理员 + 订阅 Owner，且这两者常不是同一人 |
| 检测落点 | CloudTrail（管理事件/数据事件） | Activity Log + Entra 审计/登录日志 |

**够用标准（可检验）**

| 档 | 可检验的验收动作 |
|---|---|
| 读 | 能画出「客户管什么 / 云厂商管什么」的边界，并指出**这条边界因服务类型（IaaS/PaaS/SaaS）而移动**（三家官方页都这么画）。 |
| 用 | 在免费层账号上，独立写出「谁能读某个对象存储桶」的判定路径：从 policy/role assignment 出发推导，而不是靠控制台点。 |
| 工程 | 能写出**跨云统一的资产模型**：把 S3 bucket / Azure Storage container 抽象成同一个 `object_store` 实体，并各自实现一个「是否公开可读」的判定器。这是「企业数据资产安全」产品的技术雏形。 |

---

## 2. 资产测绘 / 攻击面管理（ASM）

### 2.1 外部数据源：免费额度、认证、以及**条款陷阱**

> 这一节的结论比数字更重要：**能做研究 ≠ 能做产品**。多个"免费"数据源在条款里明确禁止商用或再分发，直接决定了你能不能拿它喂一个收费 API。

**逐项核实结果（2026-10-13）**

| 数据源 | 免费现状 | 认证方式 | 商用 / 再分发 | 官方来源 |
|---|---|---|---|---|
| **Shodan** | 存在免费账号且附带免费 API key；但官方文档**未公布免费额度的具体数字**（只写 "All Shodan accounts come with a free API plan"）。付费档：Membership **$49 一次性**（100 query credits + 100 scan credits/月、16 个监控 IP、20 页结果）；Freelancer **$69/月**（10,000 query credits）；Small Business **$359/月**；Corporate **$1,099/月**。**全部 API 档限速 1 req/s**；1 query credit = 100 条结果 | 注册邮箱 → API key；学术/研究访问需机构邮箱（.edu 等）且**仅限非商业** | 付费档标注 "Commercial Use"。官方 FAQ 明确「可以把 API 集成进你的产品，只要署名 Shodan」；但 ToS §6.5 禁止转售服务本身、§6.7 要求署名 | [developer.shodan.io/api/requirements](https://developer.shodan.io/api/requirements)、[pricing](https://developer.shodan.io/pricing)、[account.shodan.io/billing](https://account.shodan.io/billing)、[ToS](https://static.shodan.io/legal/terms.html)、[credit 类型说明](https://help.shodan.io/the-basics/credit-types-explained) |
| **Censys** | **有免费档**：Free 用户 **100 credits/月**（当月不用即作废），仅基础协议（官方称 41 种）、1 页 100 条结果、1 并发，**只有 lookup 类端点**；主机历史/CVE 数据/高级协议/正则查询均付费。买任意 credit 包（低至 $100）升级为 Starter。credit 计费：实体查询 1、标准查询 5、高级(正则)查询 8 | Personal Access Token，`Authorization: Bearer <token>`；Starter 以上需 "API Access" 角色 | **Free / Researcher / 未注册用户被明确禁止任何商业用途**；即便是付费客户，**也不得把 Censys 数据嵌入对外分发的产品/服务**（可出书面报告）。再分发需 Enterprise 或书面同意 | [pricing](https://censys.com/resources/pricing/)、[Free/Starter credits](https://docs.censys.com/docs/platform-credits-free-starter)、[数据档位](https://docs.censys.com/docs/data-access-tiers-entitlements)、[ToS](https://censys.com/terms-of-service/)、[研究访问](https://docs.censys.com/docs/research-access-to-censys-data) |
| **FOFA** | 有免费档：Registered User **300 query credits/月、3,000 条结果/月**，但页面明确标注 **"(Non-commercial only)"**；API 属付费功能。付费：Personal $49（或 $25/月）、Professional $149、Business $1,499、Corporate V2 起 $5,400/月；F 点预付：10,000 点 $6 / 100,000 点 $60 | 邮箱注册；API 需购买 VIP 激活码；开源项目负责人可申请免费会员（非商业、1 年） | 仅 Business / Corporate 档列出 "Commercial Use"；免费档明示非商业 | [en.fofa.info/vip](https://en.fofa.info/vip)、[中文 VIP 页](https://fofa.info/vip)、[API 额度](https://en.fofa.info/api/info)、[会员协议 PDF](https://en.fofa.info/ENMemberService.pdf) |
| **360 Quake** | `[未核实]`。产品站与官方文档站（`quake.360.net`、`doc.sc.360.net`）均为 JS 单页应用，curl 只拿到空壳，**读不到免费额度/积分/价格/条款原文** | 需注册登录；登录页提到《用户承诺函》 | `[未核实]` | 官网 <https://quake.360.net/>（核实当日为 SPA 空壳） |
| **BinaryEdge** | **平台已关停，无免费额度**：官方支持页写明独立平台关闭，免费与付费订阅于 **2025-03-31 23:59 GMT 全部终止**；旧的 API V2 文档页残留 "Free/Starter/Business" 字样，已过期。数据并入 Coalition Control（企业邮箱可注册免费使用） | 不适用（平台关闭） | 官方称不把扫描数据当作商业产品出售，仅用于其网络保险承保 | [BinaryEdge Transition FAQ](https://help.coalitioninc.com/hc/en-us/articles/34383910057371-BinaryEdge-Transition-FAQ)、[Coalition Control](https://coalitioninc.com/control) |
| **crt.sh** | 免费、无需账号；JSON 通过 `?output=json` 取。**官方限速：5 请求/IP/分钟**（2023-06 从 60 降下来），`:5432` PostgreSQL 接口每 IP 5 个并发连接 | 无需认证 | **找不到明确的 ToS/授权条款**；底层是公开 CT 日志数据，复用受各日志与浏览器根证书计划政策约束。（crt.sh 源码仓库为 GPL-3.0） | [crt.sh](https://crt.sh/)、[官方 Google Group 限速公告 1](https://groups.google.com/g/crtsh/c/QXQFoy331pE)、[公告 2](https://groups.google.com/g/crtsh/c/NZJntKrBdmg)、[Sectigo 官方介绍](https://www.sectigo.com/root-causes/root-causes-216-what-is-crt-sh) |
| **CertStream** | 免费公共 WebSocket：`wss://certstream.calidog.io/`，无需 key；聚合 CT 日志的证书流 | 无 | 官方页面**没有任何 ToS**；服务端与 Python 客户端均为 **MIT**；数据来自公开 CT 日志 | [certstream.calidog.io](https://certstream.calidog.io/)、[certstream-server](https://github.com/CaliDog/certstream-server)、[certstream-python](https://github.com/CaliDog/certstream-python) |
| **RDAP / WHOIS** | 协议本身免费公开、无需 key；ICANN 提供免费网页查询客户端。gTLD 注册局与注册商**自 2025-01-28 起不再被要求提供 WHOIS**，RDAP 为现行要求 | 匿名查询无需认证；协议支持差异化/认证访问（RFC 7481）；客户端经 IANA bootstrap 找权威服务器 | RDAP 是 IETF 标准，协议本身无使用限制；**数据使用受各注册局/注册商 ToS 与 ICANN 政策约束**——ICANN 的 Whois Marketing Restriction Policy 禁止把注册数据用于营销；每个 RDAP 响应**必须**通过 `notices` 对象给出该服务的 ToS | [ICANN RDAP 资源页](https://www.icann.org/en/contracted-parties/registry-operators/resources/registration-data-access-protocol)、[gTLD RDAP Profile](https://www.icann.org/gtld-rdap-profile)、[STD 95](https://www.rfc-editor.org/info/std95)、[lookup.icann.org](https://lookup.icann.org/) |
| **Rapid7 Sonar Data（原 Open Data / Project Sonar）** | **已无免费公开数据集**：`opendata.rapid7.com` 现跳转到商业产品 Sonar Data；**政策自 2022-02-10 变更**。数据集规模：8 个数据集、48,239 个文件、62.3 TB（FDNS/RDNS/HTTP(S) GET/TCP/UDP/SSL 证书） | 无自助入口：邮件 `opendata@rapid7.com` + 组织与商用场景说明 + 签商业数据授权协议（个人研究者需机构背书或商业许可） | **只允许商业授权模式**；限制：仅限正当网络安全用途、禁止攻击性/营销/线索获取用途、**数据不得批量再分发**、单资产数据仅可给资产所有者/控制者 | [Sonar Data](https://sonardata.rapid7.com/)、[opendata 说明](https://opendata.rapid7.com/about/) |
| **Common Crawl** | 免费、无需账号/API key；按月发布的爬取数据集（HTTP 下载或 AWS Open Data） | 无 | ToU（**2024-03-07 更新**）给的是「有限、不可转让、不可再许可、非独占」许可；爬取内容可能另有站点条款；官方明确建议**商用前咨询法律顾问** | [Terms of Use](https://commoncrawl.org/terms-of-use)、[FAQ](https://commoncrawl.org/faq) |
| **Cloudflare Radar** | API **免费**（附开放数据：DNS 查询、HTTP 请求、NetFlow 等） | 部分端点需 token；官方文档要求先读 get-started | **数据以 CC BY-NC 4.0 授权 → 禁止商业使用**。这是最容易被忽略的陷阱：技术上是免费 API，法律上不能拿来喂收费产品 | [Radar 文档](https://developers.cloudflare.com/radar/)、[API 资源](https://developers.cloudflare.com/api/resources/radar/) |
| **ICANN CZDS（TLD 区域文件）** | 免费，任何感兴趣方均可**申请**访问参与 gTLD 的区域文件（非即时下发，需审批） | 需注册账号 + 申请 + 获批 | 门户页声明有 Terms of Use 与 Terms and Conditions，但**条款正文需登录后才可读 → `[未核实]`** | [czds.icann.org](https://czds.icann.org/) |
| **OpenINTEL / Tranco** | 存在（OpenINTEL：主动 DNS 测量数据集；Tranco：抗操纵的站点排名表） | 未核实 | **授权条款未核实**（不做结论） | [openintel.nl](https://openintel.nl/)、[tranco-list.eu](https://tranco-list.eu/) |

**从条款得出的产品设计结论（重要）**

1. **能安全商用的"入口级"数据**只有三类：CT 日志（crt.sh / CertStream / 官方 CT log list）、RDAP、以及你自己的主动扫描。
   - CT 官方日志列表有机器可读版本：`https://www.gstatic.com/ct/log_list/v3/log_list.json`（核实当日 `version 93.12`、`log_list_timestamp 2026-10-12T13:38:39Z`），来源 <https://certificate.transparency.dev/>。
2. **Censys 的免费档不能用商用，付费档也不能"把数据嵌进产品再分发"**——这条直接排除「用 Censys 免费额度做 SaaS」的路线；同类约束在 FOFA 免费档（Non-commercial only）和 Cloudflare Radar（CC BY-NC）上重复出现。
3. **能商用的付费源里，Shodan 的条款最友好**：它在 FAQ 里正面回答「可以集成进产品，署名即可」；而 Rapid7 明确「不得批量再分发」。
4. **自建主动扫描是你唯一的"完全自主"数据源**——同时它也是唯一有法律风险的数据源（见下）。
5. **国内合规提醒**：把自己扫描到的资产数据用于对外产品，除了数据源的 ToS，还要考虑目标授权（见 §2.3 「授权边界」）。本文只给工具与事实，**合规判断需专业法律意见**。

> **crt.sh 的可用性提示（现场观察）**：核实当日（2026-10-13）`https://crt.sh/` 与 `?output=json` 均返回 **502 Bad Gateway**。这不是特例——其 2023 年的限速下调正是被流量压垮后的结果。**任何依赖 crt.sh 的产品都必须有第二条腿**（自建 CT log 消费者 / 直接查 CT 日志，或付费源的证书数据），否则你的 SLA 会被一个免费站点的宕机决定。

### 2.2 自建工具链：ProjectDiscovery 家族与替代品

**许可证这张表比功能表重要**——因为本项目要落到产品里，`GPL-3.0` / `AGPL-3.0` / `NPSL` 的差异会直接决定架构。

**ProjectDiscovery（PD）家族**（每个 repo 均已打开确认，官方文档站 <https://docs.projectdiscovery.io>、工具索引 <https://docs.projectdiscovery.io/tools>、官方开源页 <https://projectdiscovery.io/open-source>）

| 工具 | 定位（在流水线里的哪一层） | 许可证 | 版本 / 日期（核实日） | 官方仓库 |
|---|---|---|---|---|
| **subfinder** | 子域发现·**被动**（CT / 被动 DNS / 搜索引擎聚合），追求快与隐蔽 | MIT | v2.17.0 / 2026-10-08 | <https://github.com/projectdiscovery/subfinder> |
| **dnsx** | 解析与过滤层：A/AAAA/CNAME/NS/MX/TXT/SRV/PTR/SOA/AXFR/CAA、批量解析、爆破、**通配符过滤**、CDN/ASN 标注 | MIT | v1.3.1 / 2026-08-31 | <https://github.com/projectdiscovery/dnsx> |
| **tlsx** | 证书情报层：SNI/SAN/CN、证书指纹(md5/sha1/sha256)、JARM/JA3、TLS 版本与套件枚举、证书异常检测（过期/自签/不匹配/吊销） | MIT | v1.4.1 / 2026-10-08 | <https://github.com/projectdiscovery/tlsx> |
| **httpx** | 存活与指纹探针：状态码/标题/长度/TLS/技术栈(wappalyzer)/JARM/JA3/CDN/CSP/favicon hash/headless 截图 | MIT | v1.12.0 / 2026-09-08 | <https://github.com/projectdiscovery/httpx> |
| **naabu** | 快速端口扫描（SYN/CONNECT/UDP），可与 nmap 联动做服务识别 | MIT | v2.6.1 / 2026-05-05 | <https://github.com/projectdiscovery/naabu> |
| **katana** | 爬取层：标准 + headless 双模式、JS 解析、自动表单填充、scope 控制 | MIT | v1.8.0 / 2026-10-05 | <https://github.com/projectdiscovery/katana> |
| **nuclei** | 检测层：YAML 模板驱动的多协议漏洞扫描器 | MIT | v3.11.1 / 2026-08-08 | <https://github.com/projectdiscovery/nuclei> |
| **nuclei-templates** | nuclei 的模板库（官方称约 1.36 万模板、其中约 4,400 条覆盖 CVE），默认自动更新并**签名发布** | MIT | 滚动发布 | <https://github.com/projectdiscovery/nuclei-templates> |
| **shuffledns** | 主动爆破（massdns 的 Go 封装），三模式 bruteforce/resolve/filter | ⚠ **GPL-3.0**（家族里唯一非 MIT） | v1.2.1 / 2025-12-09 | <https://github.com/projectdiscovery/shuffledns> |
| **mapcidr** | 地址空间运算：CIDR 展开/聚合/切片、IP 洗牌、ASN→CIDR | MIT | v1.1.97 / 2025-10-28 | <https://github.com/projectdiscovery/mapcidr> |
| **chaos-client** | Chaos 公开数据集客户端（数据来自服务端，需 key、限速 60 req/min/ip） | MIT（客户端） | v0.5.2 / 2024-04-22 | <https://github.com/projectdiscovery/chaos-client> |
| **notify** | 通知层：把任意工具 stdout 推到 Slack/Discord/Telegram/webhook 等 | MIT | v1.0.7 / 2024-11-01 | <https://github.com/projectdiscovery/notify> |

> ⚠ **两个必须写进自己代码注释里的许可证事实**：
> 1. **shuffledns 是 GPL-3.0**（官方仓库 LICENSE 为 GNU GPL v3）。它不是 AGPL，所以「自用不分发不触发」，但**分发/集成进自有产品就触发传染性 copyleft**。
> 2. **nuclei v3.10/v3.11 起强制 JS 协议模板必须签名才能执行**（官方模板已预签名）。这是安全加固（防止有人拿 JSON 当扫描器），不是许可证变更，但会影响你自写 JS 模板的分发方式。

**替代品 / 补充件**

| 工具 | 定位 | 许可证 | 版本 / 日期 | 官方来源 |
|---|---|---|---|---|
| **OWASP Amass** | 被动 + 主动 + 图谱化的深度攻击面测绘（Maltego 集成）；比 subfinder 重、覆盖更全 | **Apache-2.0**（核实 v3.19.2 / v3.23.3 / v5 均为 Apache-2.0 —— 未发现「v3→v4 换许可证」的证据，v4 是引擎重写） | v5.1.1 / 2026-04-07 | <https://github.com/owasp-amass/amass> |
| **masscan** | 互联网级异步 SYN 扫描（自研 TCP/IP 栈） | ⚠ **AGPL-3.0**（通过网络提供服务时须向用户提供源码） | release **1.3.2 / 2021-01-31**（但 master 仍活跃，最近提交 2026-10-05） | <https://github.com/robertdavidgraham/masscan> |
| **nmap** | 服务/版本识别与 OS 指纹的参考实现，NSE 脚本引擎、Zenmap GUI、Ncat/Nping | ⚠ **NPSL（Nmap Public Source License）**：基于 GPLv2 改造，**禁止在专有硬件/软件产品中再分发或使用**；想内嵌需买 **Nmap OEM 商业授权** | **7.991 / 2026-08-06** | <https://nmap.org/npsl/>、<https://nmap.org/download.html>、商业授权 <https://nmap.org/oem/> |

> **选型结论（面向产品落地）**：**nmap 和 masscan 不能进闭源产品**（NPSL 明确禁止；AGPL 会要求你开源服务端）。真正可自由商用的是 **PD 家族（MIT）+ Amass（Apache-2.0）**。这意味着「扫描内核自研 or 用 MIT 工具」不是偏好问题，而是许可证决定的架构约束。
>
> **PD 云服务（PDCP，现品牌化为 Neo）** 是「开源核心 + 商业云」双轨：官方 pricing 页（核实日呈现 Free（$0，功能全开但为有限一次性用量）、Pay-as-you-go（约 $200/席位/月，可加购提额，年付省 12.5%）、Enterprise（定制））。**开源 CLI 本身 MIT 不受限，受限的是云服务的用量与席位** — <https://projectdiscovery.io/pricing>。

**推荐的流水线（本项目工具产品的骨架）**

```
种子域/IP
  → subfinder（被动子域，CT/被动DNS源）        ┐
  → amass（可选：图谱化深挖）                   ├─ 资产发现
  → shuffledns / dnsx -wd（主动爆破 + 通配符过滤）┘
  → dnsx（批量解析、CNAME 链、CDN/ASN 标注）
  → naabu（端口，SYN；大网段用 masscan 但注意 AGPL）
  → tlsx（证书、SAN、JARM/JA3）        ← 证书情报回流成新的子域
  → httpx（存活、标题、技术栈、favicon hash、截图）
  → katana（爬取端点/接口）
  → nuclei（模板化验证）
  → notify（告警/webhook）
  —— 每一层的 JSON 输出都落库（快照），供 §2.3 做变更检测
```

### 2.3 变更检测与告警设计

攻击面管理的价值不在「扫一次」，而在「**每天都扫，且只在你该知道的时候吵你**」。设计要点：

**（1）把资产建模成可 diff 的行**

以 `(host, port, scheme)` 作为主键，每个键存一份**指纹快照**（httpx/tlsx 的 JSON 输出已经给了大部分字段）：

| 快照字段 | 来源 | 能发现什么变更 |
|---|---|---|
| `status_code`, `title`, `content_length` | httpx | 页面被替换 / 应用下线 / WAF 拦截页 |
| `body_hash`（或 `favicon mmh3`） | httpx | 内容级变化（注意 CDN/时间戳导致的抖动，见下） |
| `tech[]`（wappalyzer） | httpx | 技术栈升级/替换（如 nginx→Apache、出现新的 admin 框架） |
| `tls.subject_an`, `tls.issuer`, `tls.not_after`, `tls.fingerprint_sha256` | tlsx / httpx | **证书换发、到期临近、签发者变化（可能是被劫持或迁移）** |
| `cdn_name`, `asn`, `cname` | httpx / dnsx | 解析指向变化（云迁移、被接管） |
| 开放端口集合 | naabu | **新端口**（最典型的"影子资产"信号） |
| 域名集合 | subfinder / CT | **新子域**（DevOps 临时环境、并购资产、钓鱼近似域） |

**（2）三类事件，三种优先级**

| 事件 | 触发 | 建议优先级 | 备注 |
|---|---|---|---|
| `NEW` | 新 host / 新端口 / 新端点（katana） | 高 | 新暴露面默认按"未审计"处理 |
| `CHANGED` | 指纹/证书/技术栈变化 | 中 | 内容类变化必须先降噪（见 (4)） |
| `GONE` | 从存活变不存活 | 低但**必须记录** | 用于回收资产清单、避免"幽灵资产"长期挂着 |
| `EXPIRING_CERT` | `not_after` 进入 30/14/7 天窗口 | 高 | 证书是最容易做成可靠告警的信号 |

**（3）CT 是变更检测的最强前置信号**

新子域通常在「被扫到」之前就已经出现在 CT 日志里。因此推荐架构是**双通道**：

- **实时通道**：订阅 CertStream（`wss://certstream.calidog.io/`，免费无 key），对匹配自己根域的新证书立即触发一次定向探测（只打新出现的名字，不要全量重扫）。也可直接消费 CT log list（<https://certificate.transparency.dev/>，机器可读列表见 §2.1）。
- **批处理通道**：crt.sh 轮询 / subfinder 定时跑 + dnsx 通配符过滤去噪。

**（4）误报/抖动的主要来源（必须在设计阶段就压掉）**

1. **泛解析（wildcard DNS）** → 用 `dnsx -wd` 或等价逻辑过滤，否则你会把「任意随机子域都解析成功」当成几万个新资产。
2. **CDN / 多 A 记录 / 轮询负载均衡** → 同一 host 不同时间解到不同 IP，导致 IP/ASN 字段天天变。**指纹必须以内容与证书为主，IP 变化默认不告警**。
3. **响应体里的时间戳/随机 nonce/CSRF token** → 直接算 body hash 会 100% 变化。要么用规范化哈希（去掉 `<input hidden>`、注释、脚本 nonce），要么只用 favicon mmh3 这类稳定指纹。
4. **WAF 拦截页 / 429 限速页** → 状态码与标题被统一替换，会产生大片"变更"。需要给「已知拦截页签名」建白名单。
5. **扫描频率过高** → 既触发抖动，也可能触发对方封禁。频率建议：**CT 实时；子域枚举 每小时–每天；httpx 每天；端口 每周；nuclei 按模板库更新触发（官方约每 3 周发一版）**。

**（5）去重与静默期（工程细节）**

- 事件去重键：`(asset_key, event_type, field, old_value→new_value)`；同一变更 24h 内只推一次。
- **静默期**：已知的、正在进行的迁移（如你在换 CDN）应能配置成 `suppress until`，否则团队会把告警静音，等于系统失效。
- 分级通知：`NEW 端口` 直接推 IM；`CHANGED 标题` 进日报；`GONE` 只入库。

**（6）"新端口/新子域"的告警阈值设计（避免一开始就被淹没）**

第一天上线的正确做法是：**先只做快照与入库，不告警**。跑满 3–7 天建立基线，再打开告警。否则你在第一天就会收到几千条 `NEW`，整个系统的可信度当场归零。

**（7）授权边界（写工具的人必须自己先想清楚）**

主动扫描（naabu/nmap/masscan/nuclei 的主动模板）会产生真实流量。**只对你拥有书面授权的资产扫描**（自己的、客户的、或明确允许的安全测试范围）。这一条不是法律免责套话：它同时决定你的产品形态——面向企业客户时，「资产归属确认 + 授权留痕」本身就是产品功能（很多 ASM 产品把这道流程做成 onboarding 步骤，是有原因的）。

---

## 3. 漏洞验证与优先级

### 3.1 nuclei 模板体系：这是本项目最值得投的"内容 + 工具"交叉点

- 官方定义：模板是 "YAML based universal language for describing exploitable vulnerabilities"，设计目标是"基于特定漏洞检查发送定向请求，**保证低到零误报（low-to-zero false positives）**" — <https://docs.projectdiscovery.io/templates/introduction>。
- 模板结构：<https://docs.projectdiscovery.io/templates/structure>；HTTP 模板入门 <https://docs.projectdiscovery.io/templates/protocols/http/basic-http>；运行与筛选 <https://docs.projectdiscovery.io/tools/nuclei/running>。
- **模板签名**：<https://docs.projectdiscovery.io/templates/reference/template-signing>（配合 §2.2 里 v3.10/v3.11 强制签名的行为）。
- 模板库许可证 **MIT**，官方开源页明确 "nuclei and nuclei-templates are MIT licensed" — <https://projectdiscovery.io/open-source>。

**模板的关键能力（决定了它能覆盖什么）**

| 维度 | 内容 |
|---|---|
| 协议 | HTTP、DNS、TCP、SSL、File、Websocket、WHOIS、Headless、**JavaScript**、**Code** |
| 判定 | matchers：word / regex / binary / status / size / **dsl** / xpath；extractors：regex / kval / json / xpath / dsl |
| 复用 | `flow`（编排多请求与条件分支）、payloads 与 attack（batteringram/pitchfork/clusterbomb）、`self-contained`（模板自带 payload，不依赖外部文件） |
| 分级 | `info.severity`（info/low/medium/high/critical）+ `tags` + 官方元数据（CVE/CWE/厂商） |

**对教学产品直接有用的三个判断**

1. **模板是"可读的漏洞知识"**：一条 YAML 就是"这个漏洞长什么样 + 怎么验证 + 证据是什么"。这比写一篇博客更适合做课程单元（学生能自己改、自己跑、自己看结果）。
2. **写模板 = 写检测逻辑的低门槛练手场**：与 §4 的 Sigma 规则结构相似（条件 + 字段 + 匹配），是通向检测工程的自然过渡。
3. **模板库的 CVE 覆盖有限**（官方称约 4,400 条覆盖 CVE，而 CVE 总量是六位数）——这既是产品的机会（针对特定行业/中间件补模板），也是必须诚实告知用户的边界。

### 3.2 误报治理：这是产品能不能卖的分水岭

官方说模板设计目标是"低到零误报"，但**在生产里你会遇到三类误报**，必须分别治理：

| 误报类型 | 典型成因 | 治理手段 |
|---|---|---|
| **版本误判** | 只靠 banner/版本号推测"存在漏洞"，但实际已打补丁/配置不同 | 优先使用**带主动验证的模板**（发特定请求看响应差异，如回显/diff/带外 OAST）；对纯版本匹配的模板在报告里标注「疑似，未验证」 |
| **环境差异** | 模板命中了错误页面、WAF 拦截页、镜像站 | 用「两次请求对比」（同参数发一个正常值 + 一个特征值，比较响应差异）；把已知拦截页签名作为排除条件；保留"最小可复现命令"作为证据 |
| **带外（OAST）误报** | interactsh 之类的带外回调被其他扫描器/搜索引擎触发 | 使用每次运行唯一的一次性 token，并校验回调来自目标 IP |

**必须内置的工程能力（否则规模化后必然失控）**

1. **自建回归集（golden set）**：准备一批"确定干净"的目标（自建实验环境 + 已修复的靶机），每次升级模板库/引擎前跑一遍，**任何命中都视为回归**。这是唯一能把「误报率」变成可测指标的方法。
2. **报告里区分「已验证」与「疑似」**：字段级标注证据类型（带外回调 / 响应 diff / 纯版本），让下游能自己决定信不信。
3. **严重度不能替代优先级**（见 §3.3）。

### 3.3 CVE 验证与优先级：分层数据源

| 数据源 | 是什么 | 现状（核实日） | 官方来源 |
|---|---|---|---|
| **CVE Program** | CVE 编号的权威分配体系（现为 CVE Foundation/MITRE 体系） | 现行；`cve.org` 为官方入口 | <https://www.cve.org/> |
| **NVD** | NIST 的 CVE 补充分析（CVSS、CPE、引用） | 现行 | <https://nvd.nist.gov/general> |
| **CVSS v4.0** | 官方评分标准，**2023-11-01 发布**，规范文档版本 1.2 | 当前版本为 v4.0（v3.1/v2 文档并存） | 规范 <https://www.first.org/cvss/v4.0/specification-document>、总览 <https://www.first.org/cvss/> |
| **EPSS** | 机器学习模型，估计「某 CVE 未来 30 天内被利用的概率」，**每天更新、对所有 CVE 输出 0–1 概率与百分位**，免费开放 CSV/API/GitHub | 现行且免费 | <https://www.first.org/epss/>（数据 <https://www.first.org/epss/data>） |
| **CISA KEV** | 「已被在野利用」的权威清单，可直接拉 JSON | 核实当日 **1,739 条**，`catalogVersion 2026.10.08` | <https://www.cisa.gov/known-exploited-vulnerabilities-catalog>（feed：`https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json`） |
| **CISA Vulnrichment** | CISA 自己给 CVE 补充 SSVC 等决策数据 | 现行 | <https://github.com/cisagov/vulnrichment> |
| **SSVC** | CISA 的「利益相关者特定漏洞分类」决策框架（不是打分，是决策树） | 现行 | <https://www.cisa.gov/ssvc> |

**优先级模型（建议直接做成产品逻辑）**

```
风险 ≠ CVSS base。
优先级 = f(是否在野利用, 暴露面, 资产价值, 利用前置条件, 缓解措施)
```

| 判定顺序 | 问题 | 数据来源 | 动作 |
|---|---|---|---|
| 1 | 这个 CVE 在 KEV 里吗？ | CISA KEV | **在 KEV → 最高优先级**，立即处置 |
| 2 | EPSS 有多高？ | EPSS 每日分 | 高百分位 → 提前排期 |
| 3 | 资产是否互联网可达？ | §2 的 ASM 数据 | 不可达的内部资产可降级 |
| 4 | 利用需要什么前置？ | CVE 描述 / 模板 diff | 需认证 / 需交互 → 降级，但记录 |
| 5 | 本资产是否真的有受影响组件？ | nuclei 主动验证 / SBOM | 无组件 → 直接关闭（不要靠版本猜） |
| 6 | 有无缓解（WAF/网络隔离）？ | 架构信息 | 有缓解 → 记录解释，不静默关闭 |

**方法论参考（官方文件，适合做课程骨架）**

- NIST SP 800-115《Technical Guide to Information Security Testing and Assessment》 <https://csrc.nist.gov/pubs/sp/800/115/final>
- PTES（Penetration Testing Execution Standard） <http://www.pentest-standard.org/index.php/Main_Page>
- OWASP WSTG（Web 测试指南） <https://owasp.org/www-project-web-security-testing-guide/>；OWASP ASVS <https://owasp.org/www-project-application-security-verification-standard/>
- OWASP Top 10 **:2025**（注意：站点已切换到 2025 版，A01 Broken Access Control / A02 Security Misconfiguration / A03 Software Supply Chain Failures / A04 Cryptographic Failures / A05 Injection / A06 Insecure Design / A07 Authentication Failures / A08 Software or Data Integrity Failures / A09 Security Logging and Alerting Failures / **A10 Mishandling of Exceptional Conditions**）— <https://owasp.org/Top10/2025/en/>
- MITRE CWE <https://cwe.mitre.org/>

**必须写进课程/文档的诚实结论**：扫描器扫出「命中」≠「可利用」。逻辑漏洞、认证后漏洞、业务逻辑与权限设计缺陷，模板化扫描**结构性看不见**。ASM 产品的正确承诺是「暴露面 + 可验证的技术漏洞」，而不是「你安全了」。

---

## 4. 检测与蓝队：现代 SOC 的必备件（含维护活跃度）

**逐项核实结果（2026-10-13）**

| 工具/框架 | 定位 | 许可证 | 版本 / 日期 | 当前状态要点 | 官方来源 |
|---|---|---|---|---|---|
| **Sysmon** | Windows 端进程/网络/文件/注册表等遥测 | Microsoft 专有免费软件（闭源） | **15.22 / 2026-09-10**；配置 schema **4.90** | 仍在积极维护。**Windows 11 起 Sysmon 可作为"内置可选功能"启用**（`Enable-WindowsOptionalFeature -FeatureName Sysmon`），官方明确内置版与独立版**不能共存**。未找到任何官方说明称 Sysmon 被并入 Defender for Endpoint。Linux 版为独立项目 <https://github.com/microsoft/SysmonForLinux>（v1.5.3 / 2026-09-10） | [官方下载页](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)、[how-to-enable-sysmon](https://learn.microsoft.com/en-us/windows/security/operating-system-security/sysmon/how-to-enable-sysmon) |
| **Sigma** | 与厂商无关的检测规则格式（写一次，转成各 SIEM 查询） | **Detection Rule License (DRL) 1.1**（GitHub 显示 "Other"） | 规则集 **r2026-07-01 / 2026-07-09**；官方称 **3000+ 条规则**；**规范 v2.1.0 / 2025-08-02** | 活跃。规则分 5 类（Generic / Threat Hunting / Emerging Threats / Compliance / Placeholder）。规范已从 1.0 → 2.0 → 2.1 正式化 | [sigmahq.io](https://sigmahq.io/)、[repo](https://github.com/SigmaHQ/sigma)、[规范 repo](https://github.com/SigmaHQ/sigma-specification)、[DRL 1.1](https://github.com/SigmaHQ/Detection-Rule-License) |
| **YARA / YARA-X** | 文件/内存特征匹配（恶意样本、IOC） | **BSD 3-Clause** | **YARA 4.5.8 / 2026-07-28**；**YARA-X 1.21.0 / 2026-09-29** | YARA 进入**维护模式**（官方 FAQ：新功能与新模块只进 YARA-X）。YARA-X（Rust 重写）官方 README 称已在 VirusTotal 生产环境扫描数十亿文件，**已声明生产可用**（但无 "1.0 GA" 标签，当前为 1.x） | [YARA 站](https://virustotal.github.io/yara/)、[YARA-X 文档](https://virustotal.github.io/yara-x/)、[repo](https://github.com/VirusTotal/yara)、[yara-x](https://github.com/VirusTotal/yara-x) |
| **Suricata** | 高性能 网络 IDS/IPS + NSM 引擎 | **GPL-2.0**（文档 CC BY-NC 4.0） | **8.0.7 / 2026-09-15**；**7.x 已 EOL**（7.0.17 为终版 / 2026-07-07） | 活跃；8.x 为当前稳定线 | [suricata.io](https://suricata.io/)、[repo](https://github.com/OISF/suricata) |
| **Zeek** | 被动式网络安全监控（NSM），产出高保真事务日志 | **BSD**（3-clause 型） | **9.0.0 (LTS) / 2026-09-14**；上一 LTS 8.0.10 | 活跃；约每 4 个月一版 + 一年期 LTS。官网定性：**不是主动防御机制**，而是被动监控 | [zeek.org](https://zeek.org/)、[docs](https://docs.zeek.org/en/current/)、[repo](https://github.com/zeek/zeek) |
| **Wazuh** | 开源 SIEM + XDR（端点与云工作负载） | **GPL-2.0**（含 OpenSSL 链接例外；非 AGPL） | **4.14.8 / 2026-09-25** | 活跃；商业开源（Wazuh Inc.），核心开源 + Wazuh Cloud 付费托管。注意周边组件许可不一（dashboard/indexer 为 Apache-2.0 fork） | [wazuh.com](https://wazuh.com/)、[repo](https://github.com/wazuh/wazuh) |
| **Velociraptor** | DFIR / 端点可见性与采集（VQL 查询语言） | ⚠ **AGPL-3.0** | **0.77.3 / 2026-10-05**（该版本为修多个 CVE 的安全更新） | 活跃；Rapid7 于 2021 收购该项目并保持开源 | [docs](https://docs.velociraptor.app/)、[repo](https://github.com/Velocidex/velociraptor)、[Rapid7 产品页](https://www.rapid7.com/products/velociraptor/) |
| **Atomic Red Team** | 按 ATT&CK 组织的原子化攻击模拟（用于验证检测能力） | **MIT** | **无版本化 release**（master 滚动；README 徽章显示约 **1,878** 个 atomics；最近提交 2026-09-05） | 活跃；持续新增测试 | [atomicredteam.io](https://atomicredteam.io/)、[repo](https://github.com/redcanaryco/atomic-red-team) |
| **MITRE ATT&CK** | 对抗行为知识库（战术/技术/组/软件） | MITRE ATT&CK Terms of Use：非排他、免版税，**允许研究与商业使用**（保留版权声明） | **v19.2 / 2026-08-06**（v19 基础版 2026-04-28） | 活跃。**v19 起 Enterprise 的 Defense Evasion 战术被拆分：Stealth (TA0005) 与 Defense Impairment (TA0112)**；v19.2 是首次 "Agile release" | [attack.mitre.org](https://attack.mitre.org/)、[STIX 数据](https://github.com/mitre-attack/attack-stix-data)、[STIX 2.0/CTI](https://github.com/mitre/cti) |
| **auditd**（补充） | Linux 审计子系统 | GPL-2.0 | 上游仓库 <https://github.com/linux-audit/audit-userspace> | 活跃 | 同上 |
| **osquery**（补充） | 用 SQL 查询操作系统状态（端点即数据库） | **Apache-2.0 OR GPL-2.0-only**（双许可，使用者自选） | <https://osquery.io/>、<https://github.com/osquery/osquery> | 活跃 | 同上 |
| **Falco**（补充） | 云原生运行时安全（内核态 syscall 检测） | **Apache-2.0** | <https://falco.org/>、<https://github.com/falcosecurity/falco> | 活跃（CNCF） | 同上 |

**注意几个"会踩坑"的许可事实**：Velociraptor 是 **AGPL-3.0**（把它嵌进你的托管服务会触发源码义务）；Wazuh 是 **GPL-2.0** 而非 AGPL（但周边组件许可不统一）；Sigma 规则库不是常见开源许可而是自订的 **DRL 1.1**（用它的规则要读条款）；Suricata 的**文档**是 CC BY-NC（软件是 GPL-2.0）——文档不能商用，这点做培训产品时要注意。

**ATT&CK 映射的正确做法（教学产品可直接复用的实验设计）**

```
原子测试（Atomic Red Team, T1xxx）
        ↓ 在受控环境执行
遥测（Sysmon / auditd / Zeek / 云审计日志）
        ↓ 规范化入库
检测规则（Sigma → 转成具体 SIEM 查询；或 Zeek 脚本/YARA）
        ↓
告警 + 覆盖度矩阵（哪些技术有规则、哪些有遥测但无规则、哪些两者都无）
```

**覆盖度矩阵是这节最值钱的产出物**：它把「我们有蓝队」这种主观说法，变成「Enterprise 有 222 个技术，我们有遥测的 X 个、有检测规则的 Y 个」这种可量化、可投标、可教学的表格。（数字口径：ATT&CK v19 Enterprise 规模约 15 战术 / 222 技术 / 475 子技术，见其版本页。）

**给本项目的落地建议**：先用 **Sysmon + auditd/osquery + Wazuh** 组成最小闭环（成本最低、跨平台），再上 **Zeek/Suricata** 做网络侧，**Velociraptor** 用于事件响应阶段（注意 AGPL）。Sigma 规则 + Atomic Red Team 用来**证明检测有效**——这一步做出来，"教学产品"才不是只会讲 PPT。

## 5. 靶场与练习（免费 / 付费现状）

> **本节状态**：[本轮中断，未核实完] — 部分平台的定价页为 JS 动态渲染或站点不可达，凡未读到官方页面的均标 `[未核实]`，不做推测。

**逐项核实结果（2026-10-13）**

| 平台 | 定位 | 免费 / 价格 | 官方来源 |
|---|---|---|---|
| **PortSwigger Web Security Academy** | Web 漏洞教学 + 实验（**对做产品最有价值的一档**） | **免费**（官方页面标题即 "Free Online Training from PortSwigger"），需注册账号；labs 按 Apprentice / Practitioner / Expert 分级 | 课程 <https://portswigger.net/web-security>、全部主题 <https://portswigger.net/web-security/all-topics> |
| **Burp Suite Certified Practitioner（BSCP）** | 配套认证：纯实操、与 Academy 同一套技能栈 | 考试：**4 小时**，2 个应用 × 3 阶段（进入任意账号 → 拿到管理员 → 读 `/home/carlos/secret`）；**开卷**、自动监考（需上传政府签发证件）、**必须使用有效的 Burp Suite Professional 订阅**并提交 Burp project 文件；证书**有效期 5 年**。考试费：**$99.00**（实测购买页 <https://portswigger.net/buy/certification> 渲染后显示 `$99.00`） | 认证页 <https://portswigger.net/web-security/certification>、考试流程 <https://portswigger.net/web-security/certification/how-it-works>、FAQ <https://portswigger.net/web-security/certification/frequently-asked-questions>、购买 <https://portswigger.net/buy/certification> |
| **Hack The Box（HTB Labs）** | 靶机 + Pro Labs + 蓝队 Sherlocks | **Free**：20 台 active Machines、80+ active Challenges、**Pwnbox 终身 2 小时试用**、无限重置、active Fortresses。**VIP+**：**$25/月 或 $223/年**（全部 retired Machines/Challenges/Sherlocks、无限 Pwnbox、隔离实例、可申 CPE）。**HTB PRO**：**$49/月 或 $490/年**（= VIP+ 全部权益 + **10 个旗舰 Pro Labs**；2026-09-30 上线；legacy Pro Labs 月/年套餐自 2026-09-30 起**对新购下架**，老订阅保原价；Q4 2026 计划加入 SOC Range） | [HTB Labs 订阅说明](https://help.hackthebox.com/en/articles/7257535-htb-labs-subscriptions)、[HTB PRO 公告](https://www.hackthebox.com/blog/htb-pro-plan-announcement)、购买入口 <https://app.hackthebox.com/vip> |
| **HTB Academy** | 结构化课程（350+ 模块、20+ 学习路径、8+ 认证） | **2026-10-12 起改为分层访问**：Student **$10/月**（Tier 0–II）、Silver **$30/月**、Gold **$95/月**（到 Tier III）、Platinum **$125/月**（到 Tier IV）；Silver Annual **$550/年**、Gold Annual **$1,400/年**（各含 2 张考试券）。单模块仍可用 cube 包购买（1,000 cubes = $200） | [官方定价变更公告](https://www.hackthebox.com/blog/new-academy-pricing)、套餐页 <https://academy.hackthebox.com/plans> |
| **TryHackMe** | 入门导向的引导式房间 | **Free $0**（仅免费房间、每天 1 小时 AttackBox 限制）；**Premium $16.99/月**，年付折合 **$10.50/月**（官方标 "Save 38%"）。以上为实测渲染 <https://tryhackme.com/pricing> 读到的数字 | <https://tryhackme.com/pricing> |
| **CyberDefenders** | **蓝队/DFIR 专项**：真实事件改编的 CyberRange 调查 | 官方提供免费入口（页面按钮 "Get started for Free" → 免费 labs 列表）；认证 **CCD 已更名 CCDL2**（官方标题 "CCDL2 (formerly CCD)"），**48 小时**实操考试。**价格 `[未核实]`** | 免费 labs <https://cyberdefenders.org/blueteam-ctf-challenges/>、平台 <https://cyberdefenders.org/blue-team-labs/>、认证 <https://cyberdefenders.org/certifications/certified-cyberdefender-level2/> |
| **LetsDefend** | SOC 模拟（SIEM 告警队列式训练） | **价格 `[未核实]`**（`/pricing` 返回 404）。⚠ **重要现状**：HTB 已将 LetsDefend 的 **191 门防御课程**与 **150+ Sherlocks** 整合进 HTB Academy，其 SOC Range 亦构建在 LetsDefend 的 SOC 模拟能力之上 —— 选型时不要把它当成完全独立的平台 | [HTB 蓝队内容整合公告](https://www.hackthebox.com/blog/blue-content-expansion) |
| **Blue Team Labs Online** | 蓝队 CTF | **`[未核实]`** —— 本轮该域名在本机网络不可达（DNS 解析异常），未能读到任何官方页面 | （无） |
| **VulnHub** | 离线 VM 靶机（可本地跑） | **免费**；官网可访问 <https://www.vulnhub.com/>。**是否仍在更新未能确证** → 相关内容标注 `[未核实]` | <https://www.vulnhub.com/> |
| **DVWA** | 经典 PHP/MySQL 教学靶场（源码级可读） | **GPL-3.0**（复核：GitHub license API 对 `digininja/DVWA` 返回 `GPL-3.0`，许可证文件是仓库根目录 `COPYING.txt`，不是 `LICENSE` —— 这正是首次取不到的原因）。⚠ 是 **copyleft**：改了源码再随课程/产品分发要满足 GPL 义务 | 仓库 <https://github.com/digininja/DVWA>、许可证 <https://github.com/digininja/DVWA/blob/master/COPYING.txt> |
| **OWASP Juice Shop** | 现代 SPA 靶场（Node/Angular），可本地部署、适合讲「现代 Web 漏洞」 | **MIT 许可**（LICENSE 原文 "Copyright (c) 2014-2026 Bjoern Kimminich & the OWASP Juice Shop contributors" + MIT 授权措辞）；仓库 <https://github.com/juice-shop/juice-shop>，官网 <https://owasp.org/www-project-juice-shop/> | 同上 |

**对这一项目的选型结论**

1. **唯一必选且免费**：PortSwigger Web Security Academy（§3 的漏洞验证能力主要靠它练）。BSCP 认证可选，且**必须先有 Burp Suite Professional 订阅**才有资格考——这是容易被漏掉的隐性成本。
2. **蓝队实验的首选**：CyberDefenders 免费 labs（真实事件、Sysmon/Elastic/取证工具全覆盖，直接对应 §4 的检测闭环）；付费认证 CCDL2 属进阶后再考虑。
3. **红队/网络渗透的付费首选**：HTB VIP+ **$25/月**（按月可停，试错成本最低）；**不要一上来买 PRO（$49/月）或 Academy Gold Annual（$1,400/年）**——先用 VIP+ + Academy Student/Silver 档验证自己是否真的会持续投入。
4. **本地靶场**：Juice Shop + DVWA 自建（免费、可离线、可改代码），适合做教学产品的实验环境；注意先确认 DVWA 的许可证再嵌入课程分发物。
5. **VulnHub 有"僵尸资产"风险**：站点在线但更新情况不明，作为课程依赖要谨慎（这与 §2.3 里讲的"幽灵资产"是同一类问题）。

## 6. 认证路径对比

### 6.1 先给结论：性价比排序（面向「有开发经验的初学者」）

**前提假设**：你的目标是「做工具/API 产品 + 教学产品」，不是进大厂 SOC 当值班分析师。这个前提**大幅改变**认证的价值排序——因为认证证明的是「你的知识体系完整度 + 雇主可验证的信号」，而产品需要的是「你把东西做出来的能力」。

**性价比排序（从高到低）**

| 排序 | 认证 | 花费（核实现行） | 为什么这样排 |
|---|---|---|---|
| 🥇 1 | **PortSwigger Web Security Academy + Burp Suite Certified Practitioner** | 学**免费**；认证另计（见 §5） | **对"做产品"最有用的一档**：免费、纯实操、内容质量高、直接对应 Web 漏洞验证（§3）；认证本身求职信号一般，但**学习价值/价格比几乎是无穷大** |
| 🥈 2 | **国内：软考「信息安全工程师」** | 报名费按省，例如北京 **57 元/科 × 2 科 = 114 元** | **对"中国求职/资质"最有用的一档**：极便宜、国家职业资格、体制内/国企/评职称可认；代价是要背教材、且信息安全工程师**近年仅下半年开考** |
| 🥉 3 | **BTL1（Blue Team Level 1，现品牌 Centri）** | **£399**（含培训 + 认证，2 次考试机会） | 务实派首选：24h 实操、**终身有效、无续证**；想建立"蓝队是干什么的"完整认知的性价比明显优于 Security+ |
| 4 | **CRTP（Altered Security）** | **$249 / $379 / $499**（30/60/90 天实验环境，含 1 次考试） | 最便宜的"真 AD 环境实操 + 考试"，3 年有效、续证考试免费；想理解 AD 攻击链时是入门最优解 |
| 5 | **Security+ （SY0-701）** | **$404**（考试）+ $150/3 年 CE 费 | 通用求职敲门砖，**但对做产品帮助很小**（纯选择题 + PBQ，无实操）。⚠ **版本切换期**：V8（SY0-801）官方标注 "Launching November 2026" |
| 6 | **CRTO（Zero-Point Security）** | **£399**（含 Cobalt Strike 授权、**考试不限次数**）；证书**不过期** | 内容比 CRTP 更深（C2/红队运营），但仍属红队方向，与"资产测绘 + 数据资产安全"主业**相关性中等** |
| 7 | **OSCP / OSCP+（OffSec）** | Learn One **$2,749/年** 或 Course+Cert **$1,749 一次性**；OSCP+ 单考 **$1,699** | 求职硬通货，**但价格相当于你半年的学习预算**。OSCP 永久有效、考试含 AD 集；OSCP+ 只是 3 年期限的同一门考试 |
| 8 | **GIAC（GSEC/GCIH/GPEN）** | **$999**/次（重考 $899、续证 $499；**不必买 SANS 课程**） | 内容好、机构认可度高（政府/大企业），但对个人开发者**性价比低**：同样的钱可以买 OSCP + BTL1 还有剩 |
| 9 | **CISSP（ISC2）** | **$749**（美洲/亚太等）；EMEA €719.04 / UK £606.69 | **不适合初学者**：需 **5 年**全职经验 + 背书人，通过后还要 120 CPE/3 年 + $135/年维持费。定位是资深/管理路线 |
| — | **国内：CISP** | 官方 2021 FAQ 列 **￥12,800**（优惠价 ￥9,600）；**现行价格官方已列为「市场调节价」**，实际以授权培训机构报价为准 `[未核实]` | 国内投标/资质场景有用（金融、运营商、政企），但对个人能力证明弱；必须走授权培训机构 |
| — | **国内：等保测评师** | `[未核实]` | **不是个人可自由报考的证书**：必须依附于有资质的测评机构（见 §6.3） |

**一句话总结**：**做产品**只需花钱在第一档（PortSwigger）+ 自己搭实验环境；**求职**的话国内看软考/CISP，国际看 BTL1（蓝队）或 OSCP（红队）。**CISSP 与 GIAC 在这个阶段都不该花这笔钱。**

### 6.2 国际认证细节（核实现行结构）

**CompTIA Security+（SY0-701，V7）** — 官方 <https://www.comptia.org/en-us/certifications/security/>、考试详情 <https://www.comptia.org/en-us/certifications/security/v7/>
- 形式：监考（Pearson VUE），最多 **90 题**（选择题 + 性能题 PBQ，**无真实机器渗透**），**90 分钟**，**750/900 通过**；5 个域（通用安全概念 12%、威胁与漏洞 22%、安全架构 18%、安全运营 28%、安全项目管理 20%）。
- 价格：**$404**（官方博客口径，2025 年 1 月；不含税，区域定价不同）。
- 有效期：**3 年**；续证 **50 CEU + $150/3 年** CE 费（若通过新版考试/取得更高级 CompTIA 认证/完成 CertMaster CE 可免）。
- ⚠ **版本过渡（必须现场核实的那类事实）**：**V8（SY0-801）** 官方页面标题为 "Security+ Certification V8 (**Coming Soon, Launching November 2026**)" <https://www.comptia.org/en-us/certifications/security/v8/>（该站对 curl 返回 403，经官方同域页面确认）。**截至 2026-10 现行仍为 SY0-701**；考生应按官方页面的退役时间安排考试。注意：具体退役日期本站未直接读到 → 相关细节 `[未核实]`。

**BTL1（Blue Team Level 1）** — 官方（已更名 Centri）<https://www.centri.org/certifications/blue-team-level-1>、考试格式 <https://support.centri.org/hc/en-gb/articles/11316638140444-BTL1-Exam-Format>
- 形式：**24 小时、开放资料的纯实操**，浏览器内的企业环境（被入侵后的现场），20 道任务题（按 ATT&CK 组织），**不监考**，**明确禁止 AI 工具/ChatGPT**；**70% 通过**（首次 90%+ 得金标）；含 **2 次**考试机会；购买后 12 个月内开考。
- 价格：**£399**（含培训 + 认证、4 个月点播、100 实验室小时、2 次考试）；官方未公布美元价。
- 有效期：**终身**，无 CPE。厂商由 Security Blue Team 更名为 **Centri**（旧域名跳转）。更高阶有 BTL2。

**OSCP / OSCP+（OffSec）** — PEN-200 课程页 <https://www.offsec.com/courses/pen-200/>、OSCP+ 独立考试页 <https://www.offsec.com/products/oscp-plus/>、考试指南 <https://help.offsec.com/hc/en-us/articles/360040165632>
- **现行考试结构**：完全实操、OffSec 监考 + 私有 VPN；**23 小时 45 分**作答 + 额外 **24 小时**交报告；**3 台独立靶机（各计 10 分初始访问 + 10 分提权）+ 1 组 Active Directory（3 台，40 分，假定已被入侵场景）**，**70/100 通过**；Metasploit 只允许对 1 台使用；禁止群扫、欺骗与 AI 聊天工具。
- **OSCP 与 OSCP+ 的关系（用户最常问的"是否改版"）**：**不是两门考试**。2024-11-01 之后通过 OSCP 考试的考生**同时获得 OSCP 与 OSCP+**；两者**唯一的区别是有效期**——**OSCP 永久有效**，**OSCP+ 自签发起 3 年到期**（官方原文：差异 "in only one way; it will expire three (3) years from issuance"）。2024 年的变化是**新增 OSCP+ 这个时限性标识**，不是改了考试内容（含 AD 集的考试结构是更早的 2022 年重构）。
- OSCP+ 续期三条路径：到期前 6 个月内通过重认证考试 / 通过 OSEP、OSWA、OSED、OSEE 之一 / 完成 OffSec CPE 项目。
- 价格：**Learn One $2,749/年**（1 门课 + 实验 + 2 次考试，自动续订）；**Course + Cert Bundle $1,749 一次性**（90 天实验 + 1 次考试）；**OSCP+ 独立考试 $1,699 一次性**（90 天内 2 次机会，不含课程）。无单独"仅考 OSCP"的购买选项。

**CRTP（Altered Security）** — 官方 <https://www.alteredsecurity.com/adlab>
- 形式：在**全补丁的企业 AD 环境**（多域/多林）进行 **24 小时**实操考试；1 台立足学生机 + **5 台目标服务器**，需在全部 5 台上实现命令执行；考的是**特性滥用**而不只是漏洞利用。
- 价格：**$249 / $379 / $499**（对应 30/60/90 天实验环境），含视频课程、课程材料终身访问、云学生机、**1 次考试**；重考 **$99**。
- 有效期：**3 年**，到期前**免费**重认证考试（首次免费，之后 $29）；累计续期超过 6 年后转为永久。

**CRTO（Zero-Point Security，隶属 Fortra）** — 官方 <https://www.zeropointsecurity.co.uk/course/red-team-ops>
- 形式：实操 CTF 式假定被入侵场景（通过 Snap Labs 的 Guacamole 界面，无 VPN/互联网）；**8 台靶机/flag，至少拿下 6 个（75%）通过**；考试为 **48 小时运行时长，4 天窗口内使用，VM 可暂停**；**不限考试次数**。
- 价格：**£399**（含 20 小时课程、20+ 实验、**Cobalt Strike 授权**、终身访问、不限次考试）；RTO + RTO II 打包 £765；官方未公布美元价。
- 有效期：**不过期**（官方 FAQ 明确）。RTO II 对应 "Red Team Lead" 认证。
- **别名提醒**：CRTP（Altered Security）与 CRTO（Zero-Point）是**两家不同厂商、两门不同考试**，常被混称。

**GIAC（GSEC / GCIH / GPEN）** — 官方 <https://www.giac.org/certifications/security-essentials-gsec>、<https://www.giac.org/certifications/certified-incident-handler-gcih>、<https://www.giac.org/certifications/penetration-tester-gpen>、价格 <https://www.giac.org/pricing>
- 形式：监考（ProctorU 远程 / Pearson VUE 现场），**CyberLive 实操 VM 题 + 选择题**：GSEC **106 题 / 4 小时 / 72% 通过**；GCIH **106 题 / 4 小时 / 69%**；GPEN **82 题 / 3 小时 / 73%**；激活后 120 天内考试。
- 价格：**$999/次**（重考 $899、延期 $479、模拟考 $399、续证 $499）。
- **关键事实**：**GIAC 不要求购买 SANS 课程即可报名考试**（SANS 课程只是官方推荐备考路径）。这一点与"GIAC 必须搭配 SANS 课程"的流传说法不同。
- 有效期：**4 年**；续证需 **36 CPE + $499**（2 年内再次续证 $249），或重考。

**CISSP（ISC2）** — 官方 <https://www.isc2.org/certifications/cissp>、价格 <https://www.isc2.org/register-for-exam/isc2-exam-pricing>
- 形式：CAT 自适应机考，**3 小时、100–150 题、700/1000 通过**；8 个域（安全与风险管理 16%、资产安全 10%、安全架构与工程 13%、通信与网络安全 13%、IAM 13%、安全评估与测试 12%、安全运营 13%、软件开发安全 10%）。
- 价格：**$749**（美洲/亚太/中东/非洲）；EMEA **€719.04**、UK **£606.69**（不含税；改期 $50、取消 $100）。
- **先决条件（对初学者是硬门槛）**：需 **5 年**累计全职带薪经验（覆盖 2 个以上域），最多可减免 1 年（学历或指定认证）；**必须由一位在册 ISC2 持证人背书**；经验不足者可先通过考试成为 "Associate of ISC2"（6 年内补足经验），通过后 9 个月内须提交申请。
- 有效期：**3 年**；需 **120 CPE/3 年**（建议 40/年，最多滚动 40）+ **$135/年** 维持费（Associates/CC 为 $50）；逾期有 90 天宽限，之后暂停。

### 6.3 国内认证细节

**软考「信息安全工程师」（中级，水平考试）** — 官方 <https://www.ruankao.org.cn/>、考试说明 <https://www.ruankao.org.cn/article/content/bkzn/02_47.html>、报名入口 <https://bm.ruankao.org.cn/sign/welcome>
- 主办：人社部 + 工信部共同组织（考务由工信部教育与考试中心承办）。
- 形式：**现行全部机考**；中级为「基础知识」+「应用技术」**两科连考、总时长 240 分钟**（基础知识最长 120 分钟、最短 90 分钟），**须一次考试内通过全部科目，成绩不滚动**。
- 开考频次：软考原则上每年上/下半年各一次，但**信息安全工程师近年仅下半年开考**（2025 年为 11 月 8–11 日；2026 年为 10 月 24–27 日）。
- 费用：**各省自定**。可核实的官方示例：**北京 57 元/人·科**（依据京发改〔2022〕375 号），信息安全工程师 2 科共 **114 元**；来源为北京市人事考评办公室《关于北京地区 2026 年下半年计算机技术与软件专业技术资格（水平）考试工作的通知》（京人考发〔2026〕29 号） <https://rsj.beijing.gov.cn/ywsite/bjpta/zcwj/2026zc/202609/P020260902684766185975.pdf>
- 有效期：官方页面**未规定有效期，也未提出继续教育要求**，官网考试简介称证书在全国范围内有效 <https://www.ruankao.org.cn/introduction/main.html>。（即：按公开页面为长期有效；官方未使用"永久有效"字样。）
- 报考条件：**无学历、资历限制**；报名属地化管理（如在北京考区需现工作地或居住地在北京）。

**CISP（注册信息安全专业人员）** — 官方 <https://www.itsec.gov.cn/ryzc/>、官方 FAQ <https://www.itsec.gov.cn/ryzc/rsqsxz/202107/P020210708067907957045.doc>
- 发证机构：中国信息安全测评中心。**必须经授权培训机构报名**，完成规定课时培训后参加考试（2025 年 11 月 1 日起中心强化报考资料初审，不合格者取消成绩 <https://www.itsec.gov.cn/zxxw/202509/t20250929_236941.html>）。
- 形式：**120 分钟、100 道单选、70 分通过**（部分城市机考）。
- 价格：中心的官方《综合性涉企收费目录清单》（2025-09-16）已将 CISP 培训费、考试费列为**「市场调节价、双方协商确定」**，未公布固定数字 → **现行价 `[未核实]`**。2021 年官方 FAQ 载明 **￥12,800**（优惠价 **￥9,600**），含考试费 1000 + 三年年金 1500 + 培训管理费 1000 + 制证费 500 + 培训费 8800。
- 有效期：**3 年**；首次培训费含前三年维持费，之后**500 元/年**，需向授权维持机构提交申请。
- 报考条件：硕士及以上满 1 年 / 本科满 2 年 / 专科满 4 年，且有 1 年以上信息安全相关工作经历；经验不足可先取得培训合格证书、3 年内补足再注册。

**CISP-PTE / CISP-PTS（渗透测试方向）** — 官方 FAQ 收录 <https://www.itsec.gov.cn/ryzc/rsqsxz/>
- 官方定位：**CISP-PTE** 面向渗透测试实施、漏洞验证、方案与用例制定、报告输出；**CISP-PTS** 面向高级渗透测试，需具备漏洞研究、代码分析与方案策划能力。
- 具体**考试形式/时长/题量官方页面未载明 → `[未核实]`**；价格/有效期亦未单列 → `[未核实]`。
- 该方向由中国信息安全测评中心授权的运营机构（奇安信网神）负责课程、平台与考试实施。

**网络安全等级测评师（俗称"等保测评师"）** — 官方依据：公安部第十一局《网络安全等级保护测评机构管理办法》（公信安〔2018〕765 号） <http://gxxxzx.gxzf.gov.cn/szjcss/wlyxxaq/P020200429541616034689.pdf>、推荐目录发布站 <https://www.djbh.net/>
- **最重要的结论：这不是个人可自由报考的证书。** 路径是「单位先申请成为测评机构 → 机构组织本单位人员参加测评师培训并考试」（《办法》第十条）；即**证书依附于机构资质**。
- 测评机构条件（《办法》第七条）：境内注册、注册资金 500 万元以上、从事网络安全服务两年以上、相关技术与管理人员不少于 15 人（专职渗透测试不少于 2 人），且**至少 15 人取得测评师证书**（高级不少于 1 人、中级不少于 5 人）。
- 有效期与管理：测评师证书**年度注册**；每年培训不少于 40 学时，不足不予年度注册；一年内未参与测评活动或离职一年内未再入职测评机构的，证书被注销。测评机构推荐证书有效期 3 年。
- 费用：`[未核实]`（《办法》未规定，官方页面未见收费标准）。

**顺带更正一个常见混淆（NISP / CCSC / CCRC）**
- **NISP（国家信息安全水平考试）** 是官方名称，由测评中心运营 <https://www.itsec.gov.cn/ryzc/rsqsxz/nisp/>；二级被称为"CISP 校园版"（满足 CISP 条件后可免培免考换 CISP 证书）；二级新证 **有效期最长 5 年**。(2025-07-15 公告)
- 流传的 **"CCSC"** 未能在权威官方来源（itsec / ruankao）找到与 NISP 的对应关系 → `[未核实]`。
- **CCRC**（中国网络安全审查认证和市场监管大数据中心 <https://www.isccc.gov.cn/>）负责的是**信息安全服务资质认证**与人员认证（CISAW 等），**与公安部等保体系的"等保测评师"不是同一体系**，注意别混。

### 6.4 「求职有用」vs「对做产品有用」——一句话对照

| 认证 | 求职信号（中国） | 求职信号（国际/远程） | 对做产品的帮助 |
|---|---|---|---|
| 软考 信息安全工程师 | **中高**（体制内/国企/评职称、部分招投标加分） | 低（海外基本不认） | 低（但教材体系适合补理论盲区） |
| CISP | **高**（金融/运营商/政企投标常被要求） | 低 | 低 |
| 等保测评师 | 高（但**只在测评机构内**） | 无 | 中（若你做等保相关工具，懂测评方法论是刚需） |
| Security+ | 中（外企/部分岗位加分） | 中（HR 过滤线） | 低（无实操） |
| BTL1 | 低-中 | 中高（蓝队入门可验证） | **中高**（24h 实操 + ATT&CK 视角直接可用） |
| OSCP/OSCP+ | 中（安全公司认） | **高**（渗透岗硬通货） | 中（做题能力 ≠ 做产品，但"能验证漏洞"是产品能力） |
| CRTP / CRTO | 低 | 中（红队方向） | 中（AD 攻击链知识对"数据资产安全"有价值） |
| GIAC | 低 | 中高（政府/大企业） | 低（性价比差） |
| CISSP | 低（资历不足） | 高（管理/资深岗） | 低 |
| **PortSwigger 免费课程 + 认证** | 中 | 中 | **最高**（内容免费、纯实操、直接对应 §3 漏洞验证） |

---

## 7. 知识清单（按依赖顺序）

读法：**L0 一小时级（建立词汇）→ L1 一天级（能做小实验）→ L2 一周级（能做出可交付物）→ L3 长期（需要反复做才内化）**。"必须动手"列标 ⚙ 的，只看书等于没学。

### L0 · 一小时级：建立词汇（读书即可）

| # | 主题 | 依赖 | 产出 |
|---|---|---|---|
| 1 | 资产 / 攻击面 / 暴露面（asset、attack surface、exposure）三个词的差别 | 无 | 能用自己的话解释「同一台机器，暴露面随部署位置变化」 |
| 2 | CVE / CVSS / CWE / CPE / CNA 各是什么、谁维护 | 无 | 能指出一条 CVE 的哪个字段来自哪个体系 |
| 3 | 认证 vs 授权 vs 审计（authentication / authorization / auditing） | 无 | 能解释「权限提升」为什么是授权问题而非认证问题 |
| 4 | 责任共担模型（三种服务形态各切在哪） | 无 | 画出 IaaS/PaaS/SaaS 的责任线 |
| 5 | MITRE ATT&CK 的结构（战术 / 技术 / 子技术 / 软件 / 组） | 无 | 能查出一项技术属于哪个战术 |
| 6 | OWASP Top 10:2025 十个类目 | 无 | 能说出前三个类目各自对应哪类代码缺陷 |
| 7 | 漏洞管理 vs 攻击面管理 vs 暴露面管理的区别（本文 §2/§3 的边界） | 1,2 | 能解释为什么 ASM 产品会变成「持续服务」而不是「一次性报告」 |

### L1 · 一天级：能做小实验（⚙ 必须动手）

| # | 主题 | 依赖 | ⚙ | 可检验产出 |
|---|---|---|---|---|
| 8 | TLS 握手与证书链（RFC 8446 / 5280） | L0-1,3 | ⚙ | 用 `openssl s_client` 手工验证一条链并解释每级签名 |
| 9 | SNI / HSTS / CAA 各自解决什么问题 | 8 | | 能说出「为什么 SNI 泄漏在共享 IP 托管里是隐私问题」 |
| 10 | CT 日志与证书情报（RFC 9162） | 8 | ⚙ | 对一个域名列出它全部 CT 记录，找出最早的签发时间 |
| 11 | DNS 记录类型与 CNAME 链、泛解析 | L0-1 | ⚙ | 用 `dnsx`/`dig` 识别一个域是否泛解析 |
| 12 | HTTP 请求走私/头注入的**原理**（不要求利用） | 11 | | 能解释 Content-Length 与 Transfer-Encoding 冲突为什么危险 |
| 13 | auditd / journald / Sysmon 各自的遥测覆盖 | L0-3 | ⚙ | 抓到一次「进程执行 + 网络连接」并落成结构化事件 |
| 14 | 云审计日志（CloudTrail / Azure Activity Log）看懂几条关键事件 | L0-4 | ⚙ | 从日志中定位「谁在什么时候把存储桶改成公开」 |
| 15 | 基本 Web 漏洞的**验证**（不是利用）：XSS/SQLi/IDOR | 12 | ⚙ | 在 PortSwigger Academy 上独立完成 XSS 与 access control 各 3 个 lab |

### L2 · 一周级：能做出可交付物（⚙ 必须动手，这是产品能力的起点）

| # | 主题 | 依赖 | ⚙ | 可检验产出（= 产品雏形） |
|---|---|---|---|---|
| 16 | 子域枚举流水线（subfinder → dnsx → httpx） | 11 | ⚙ | 对一个**你自己拥有**的域名产出存活资产表（含标题/技术栈/证书） |
| 17 | 端口扫描与暴露面判断（naabu/nmap；注意许可证） | 16 | ⚙ | 产出「开放端口 + 是否互联网可达 + 服务指纹」表 |
| 18 | 资产指纹与快照设计 | 16,17 | ⚙ | 写一个能存快照并 diff 出 NEW/CHANGED/GONE 的脚本 |
| 19 | 变更检测的降噪（泛解析、CDN、动态内容） | 18 | ⚙ | 在含 CDN 的目标上做到「无变更时不告警」 |
| 20 | CT 驱动的实时发现（CertStream / CT log list） | 10,18 | ⚙ | 新证书出现后 60 秒内触发一次定向探测 |
| 21 | nuclei 模板：用官方模板 + 改一条自己的模板 | 15 | ⚙ | 写出一条针对特定中间件版本的模板并说明判定依据 |
| 22 | 漏洞优先级模型（KEV + EPSS + 暴露面） | 2,17,21 | ⚙ | 输入 CVE 列表 → 输出排序后的处置队列，且能解释每条排序理由 |
| 23 | 误报治理（golden set 回归） | 21 | ⚙ | 建一个"确定干净"的集合，任何命中都算回归 |
| 24 | Sigma 规则与日志源映射 | 13,14 | ⚙ | 把一条 Sigma 规则转成你实际日志平台的查询并跑通 |
| 25 | 原子测试到检测的闭环（Atomic Red Team） | 23,24 | ⚙ | 执行一个 atomic → 在你的遥测里找到对应痕迹 → 你的规则报警 |
| 26 | 覆盖度矩阵 | 5,25 | ⚙ | 产出 ATT&CK 技术 × {有遥测/有规则/都没有} 的表格 |

### L3 · 长期：需要反复做才内化（这类能力不能靠读，只能靠"做过 N 次"）

| # | 能力 | 为什么长期 | 怎么定义"有进展" |
|---|---|---|---|
| 27 | **真实环境里的漏洞验证判断力**（什么时候该信扫描结果） | 误报与漏报的真实分布只能靠累积 | 能对每条告警给出「我怎么验证过它」的一句话证据 |
| 28 | **资产归属与变更的语义理解**（这条变化是恶意，还是业务在发布？） | 需要理解客户的业务节奏 | 告警的"被采纳率"上升、静音率下降 |
| 29 | **数据资产分级与访问路径分析**（谁→通过什么角色→能读什么数据） | 跨云、跨系统、跨团队的路径需要真实案例 | 能画出一份"从外部身份到敏感数据的可达路径"图 |
| 30 | **检测工程调优**（误报率与召回率的持续权衡） | 规则会随环境漂移 | 能给出规则集随时间的误报/漏报趋势 |
| 31 | **应急响应与取证纪律**（证据链、时间线、可复现） | 只有真出事才练得出来；但可以用演练替代 | 完成一次完整演练（攻击→发现→取证→报告）并复盘 |
| 32 | **合规与授权边界**（数据源 ToS、扫描授权、数据出境） | 政策与条款持续变化（本文 §2.1 就是活例） | 每个数据源都有书面的"能用/不能用在哪"结论 |

### 7.1 学习顺序的一张图（按依赖）

```
L0 词汇
  └─ L1 单点实验（TLS/证书 → DNS → HTTP → 日志/遥测 → 云日志 → Web 漏洞验证）
       └─ L2 流水线与闭环
            ├─ 测绘线：16 → 17 → 18 → 19 → 20
            ├─ 验证线：15 → 21 → 22 → 23
            └─ 检测线：13/14 → 24 → 25 → 26
                 └─ L3 长期：27/28/30（测绘+验证线）· 29（数据资产线）· 31/32（全都要）
```

### 7.2 按每周 10–15h 的节奏（参考排期，不含认证考试）

| 周 | 主题 | 交付物 |
|---|---|---|
| 1–2 | L0 + TCP/IP + 抓包（§1.1） | 抓包分析报告：一个 HTTPS 会话的完整画面 |
| 3–4 | DNS / TLS / 证书（§1.2） | 「域名-证书-到期」资产表脚本 |
| 5 | Linux 遥测 + 云审计日志（§1.3/§1.4） | 统一 schema 的事件采集器 |
| 6–7 | 子域/端口/指纹流水线（§2.2） | 自建扫描流水线 v1 + 快照入库 |
| 8 | 变更检测与降噪（§2.3） | 能在有 CDN 的目标上做到零噪声告警 |
| 9–10 | nuclei 模板与误报治理（§3） | 自写 2 条模板 + golden set 回归脚本 |
| 11–12 | 优先级模型（§3.3） | KEV+EPSS+暴露面的排序服务（可为 API 雏形） |
| 13–14 | 蓝队闭环（§4） | Atomic → 遥测 → Sigma → 告警 的端到端演示 + 覆盖度矩阵 |
| 15+ | 综合 | 把上面拼成一个"企业资产暴露面日报"的可演示产品 |

---

## 8. 核实状态与未核实项（诚实清单）

**已现场核实到官方页面**（本文所有数字/版本/价格均来自这些页面，核实日 2026-10-13）：
RFC 9293/9110/9112/8446/6066/6797/5280/6962/9162/8659/8484/4033/8555/7480（rfc-editor）；Wireshark 4.6.9、tcpdump 4.99.7；AWS/Azure 责任共担与 IAM/RBAC 官方页、MCSB v2 (preview)、NIST SP 800-207/53r5/800-61r3/800-115、NIST CSF、CIS Benchmarks；Shodan/Censys/FOFA/Rapid7/Common Crawl/Cloudflare Radar/crt.sh/CertStream/RDAP/CZDS 官方页与条款页；BinaryEdge 关停 FAQ；PD 各工具官方 repo/LICENSE/release；Amass/masscan/nmap 官方 LICENSE 与版本；nuclei 模板官方文档与签名文档；CVSS v4.0 规范、EPSS、CISA KEV（JSON feed）、Vulnrichment、SSVC、OWASP Top 10:2025；Sysmon/Sigma/YARA/YARA-X/Suricata/Zeek/Wazuh/Velociraptor/Atomic Red Team/ATT&CK v19.2；Falco/osquery/audit-userspace；Security+/V8 状态、BTL1、OSCP/OSCP+、CRTP、CRTO、GIAC、CISSP；软考、CISP、CISP-PTE/PTS、等保测评师管理办法、NISP。

**`[未核实]` 清单（不要当成事实用）**：

1. **360 Quake** 的免费额度、积分制度、API 价格与条款 —— 官方站点为 JS 单页应用，curl 只得到空壳；官方文档站（doc.sc.360.net）同样无法读取。
2. **crt.sh 的 ToS / 数据再分发授权** —— 官网未见明确条款（且核实当日站点返回 502）。
3. **CertStream 的数据商业使用授权** —— 官方页面无 ToS（代码为 MIT，但"代码许可"≠"数据许可"）。
4. **ICANN CZDS 的 Terms of Use 正文** —— 需登录后才可读。
5. **OpenINTEL / Tranco 的授权条款**。
6. **CISP 现行价格**（官方已列为市场调节价；2021 年 FAQ 的 ￥12,800 可能过时）。
7. **CISP-PTE / CISP-PTS 的考试形式、时长、题量、价格、有效期**。
8. **等保测评师的培训/考试收费标准**。
9. **"CCSC" 与 NISP 的对应关系**。
10. **CompTIA Security+ V7 的具体退役日期**（官方 V8 页面标题仅标注 "Launching November 2026"，本站对 curl 403，未直接读到退役日期）。
11. **Shodan 免费账号的具体月度 credit 数字**（官方仅称 "comes with a free API plan"）。
12. **FOFA VIP 页「$1,499 / $1,199 per month」对应的计费周期**（页面为月/年切换控件，渲染后周期归属不明确；已按原文并列记录两个数字）。
13. **PDCP（现 Neo）Pay-as-you-go 档的精确价格与用量上限**（页面为动态渲染，价格约为 $200/席位/月）。
14. **Censys 是否存在名为 "diff" 的独立 API** —— 未见公开端点，其能力体现在 ASM 的资产清单/事件（Logbook）与告警；本文因此表述为「ASM 资产变更/事件监控」而非"diff API"。

**服务可用性观察（非缺陷，但对产品设计有直接影响）**：核实当日 `crt.sh` 返回 502；`comptia.org`、`centri.org`、`binaryedge.io`、`radar.cloudflare.com` 对自动化请求返回 403（Cloudflare 反爬）——**任何依赖第三方站点的产品都要为此设计降级路径，本次核实过程本身就是一次小型「外部依赖脆弱性」演示**。

---

### 附：本文与仓库其他文档的关系

- 本文负责「**攻击面测绘与技能树**」这一层的判断与证据。
- 工具链的**产品化落地**（API 设计、数据模型、计费、部署）与**教学产品的课程结构**不在本文范围，应在后续文档中单独展开。
- 所有许可证结论（MIT / GPL-3.0 / AGPL-3.0 / NPSL / DRL / CC BY-NC）都是**架构约束**，建议在架构评审时把本文 §2.2 与 §4 的许可证列直接当作输入。
