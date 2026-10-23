# 安全与企业数据资产 Resources

本工作区的可信来源清单。**课程里的事实性结论只能从这里取**，不要凭记忆写。
每条都标了「用在哪」—— 三个月后裸链接就没用了。

所有链接均于 2026-10-13 实测可达；当时不可达或被反爬拦截的已就地标注。

## Knowledge

### 情报与优先级（M2）

- [CISA KEV 目录](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) · [JSON feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) · [许可 CC0 1.0](https://www.cisa.gov/sites/default/files/licenses/kev/license.txt)
  用在哪：判断「是否已被在野利用」。这是唯一**免费、无 key、许可最宽松（CC0）**的硬信号源，日报骨架由它撑起。
- [FIRST EPSS 项目页](https://www.first.org/epss/) · [How EPSS Works](https://www.first.org/epss/how-it-works) · [Get the Data](https://www.first.org/epss/data) · [API 文档](https://api.first.org/epss/)
  用在哪：概率与分位的语义、为什么它不是严重度；批量取数走 CSV，按需查询走 API。
- [CISA SSVC 决策模型](https://www.cisa.gov/stakeholder-specific-vulnerability-categorization-ssvc) · [SSVC Guide (PDF)](https://www.cisa.gov/sites/default/files/publications/cisa-ssvc-guide%20508c.pdf)
  用在哪：把「先修哪个」变成可复述的决策规则，替代自创评分。
- [NVD API 文档](https://nvd.nist.gov/developers/vulnerabilities)
  用在哪：需要 CVE 富化字段时。注意限速：无 key 5 req/30s、有 key 50 req/30s，按 `lastMod` 增量拉取。
- [OSV.dev API](https://google.github.io/osv.dev/api/) · [GitHub Global Advisories REST](https://docs.github.com/en/rest/security-advisories/global-advisories)
  用在哪：开源生态漏洞、包管理器视角。OSV 免费无 key；GHSA 未认证 60 req/h。
- [CVSS v4.0 规范](https://www.first.org/cvss/v4.0/specification-document) · [CVSS FAQ](https://www.first.org/cvss/v4.0/faq)
  用在哪：讲清「严重度 ≠ 被利用可能性」的官方依据。
- 信噪比与去重：同一漏洞会以 CVE/GHSA/OSV/厂商公告多份出现，**必须先按 CVE 对齐再聚合**（见 `docs/research/01` §4.4）。

### 分类与框架（M2/M4）

- [MITRE ATT&CK 版本页](https://attack.mitre.org/resources/versions/)（当前 **v19.2**）· [CWE 数据](https://cwe.mitre.org/data/index.html)（当前 **4.20**）
  用在哪：攻击行为分类（ATT&CK）与弱点分类（CWE）的官方口径；做映射表时引用版本号。
- [OWASP Top 10:2025](https://owasp.org/projects/top-ten) · [OWASP API Security Top 10（现行仍是 2023）](https://owasp.org/API-Security/editions/2023/en/0x11-t10/) · [OWASP Data Security Top 10](https://owasp.org/projects/data-security-top-10)
  用在哪：应用层/API 层/数据层缺陷类目。注意三者**版本年份不同**，别混着引用。

### 协议与网络地基（M1）

- RFC 原文（rfc-editor 页面即正文）：[RFC 9293 TCP](https://www.rfc-editor.org/rfc/rfc9293) · [RFC 9110 HTTP 语义](https://www.rfc-editor.org/rfc/rfc9110) · [RFC 9112 HTTP/1.1](https://www.rfc-editor.org/rfc/rfc9112) · [RFC 8446 TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446) · [RFC 5280 证书与 CRL](https://www.rfc-editor.org/rfc/rfc5280) · [RFC 9162 CT v2](https://www.rfc-editor.org/rfc/rfc9162) · [RFC 6962 CT v1](https://www.rfc-editor.org/rfc/rfc6962)
  用在哪：一切协议结论的最终依据。写课程时**引 RFC 而不是引博客**。
- [Wireshark 显示过滤器速查](https://www.wireshark.org/docs/dfref/) · [tcpdump/pcap-filter 手册](https://www.tcpdump.org/manpages/pcap-filter.7.html)
  用在哪：抓包实验的查表工具。

### 数据资产与合规（M4）

- 《网络安全法》[修正决定](http://www.npc.gov.cn/c2/c30834/202510/t20251028_449048.html) · [修正后全文](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)
  用在哪：**引用条文号前必查** —— 2025-10-28 修正、2026-01-01 施行，条文已重新编号（日志留存现为新第 23 条第（三）项）。
- [《网络数据安全管理条例》全文](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) · [《数据安全法》](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html)
  用在哪：数据分类分级义务、年度风险评估义务的产品化映射。
- [GB/T 43697-2024 数据分类分级规则（国标全文公开系统）](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F0C385EDC38CBF277AEC021F23126ADE)
  用在哪：**分类分级引擎的算法本体**（8 分级要素、6 影响对象 × 3 影响程度 → 级别）。项目 3 的核心依据。
- [GB/T 22239-2019 等保 2.0](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=BAFB47E8874764186BDB7865E8344DAF) · [GB/T 37988-2019 DSMM](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=3CFD5E5A14C24D303EA1E139E6EB75C8) · [GB/T 37964-2019 去标识化](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=C8DF1BC2FB43C6EC0E602EB65EF0BC66) · [GB/T 45577-2025 数据安全风险评估方法](https://std.samr.gov.cn/gb/search/gbDetailed?id=33D40F1161195D92E06397BE0A0A5B93) · [JR/T 0197-2020 金融数据分级](https://cfstc.pbc.gov.cn/bzgk/detail?bzId=1873&id=0)
  用在哪：验收基线、成熟度评分、脱敏降级的合规依据、行业口径叠加。标准正文需在公开系统的**在线预览**里看。
- [ISO/IEC 27001:2022](https://www.iso.org/standard/27001) · [ISO/IEC 27701:2025](https://www.iso.org/standard/27701) · [NIST CSF / SP 800-53 Rev.5](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final)
  用在哪：国际体系认证与控制项清单。**27701 认新版 2025，别引 2019（已 Withdrawn）**。

### 动手练习与实验（M1–M4）

- [PortSwigger Web Security Academy](https://portswigger.net/web-security)（免费）
  用在哪：Web 漏洞验证的唯一必选动手场；labs 分 Apprentice/Practitioner/Expert。**这是本清单里性价比最高的一条。**
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)（MIT）· [DVWA](https://github.com/digininja/DVWA)（**GPL-3.0**，许可证文件是 `COPYING.txt`）· [Kubernetes Goat](https://github.com/madhuakula/kubernetes-goat)（MIT）
  用在哪：本地/离线教学靶场。⚠ DVWA 是 copyleft，改后随课程分发要满足 GPL 义务。
- [Sigma 规则库](https://github.com/SigmaHQ/sigma) · [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)
  用在哪：检测规则与「可验证的检测」—— 用原子测试证明你的规则真的会响。
- [Microsoft Presidio 文档](https://data-privacy-stack.github.io/presidio/)（MIT）
  用在哪：PII 识别引擎。**默认只支持英文**，中文要另接 Stanza / HanLP（Apache-2.0）。
- [Presidio 多语言说明](https://data-privacy-stack.github.io/presidio/analyzer/languages/)
  用在哪：评估中文识别可行性的第一站，别等接完了才发现语言不支持。

### 本仓库自己的证据层

- `docs/research/01`–`04`（约 2300 行，每条断言带一手来源，核实日 2026-10-13）
  用在哪：设计决策/选型/合规判断的快速检索。⚠ 它们是**二手加工**，对外引用时请回链到其中的一手来源，而不是引用本仓库。

## Wisdom (Communities)

学到的知识要在真实环境里被挑战过才算你的。

### 中文

- [先知社区](https://xz.aliyun.com/)（阿里云安全）
  质量较高的中文技术社区，偏实战与漏洞分析。用在哪：看别人怎么把漏洞讲清楚（这正是你要练的产出形态）。
- [安全客](https://www.anquanke.com/)
  安全资讯与深度文章。用在哪：跟踪国内事件与厂商动态。
- [看雪论坛](https://bbs.kanxue.com/)
  逆向与二进制方向的老牌社区。用在哪：需要理解"攻击者视角"时。
- [FreeBuf](https://www.freebuf.com/)
  资讯门户，量大而杂。用在哪：知道发生了什么；**不要**把它当结构化事实源（实测对非浏览器请求返回 405，也说明它的定位是"人读"）。
- [CNNVD](https://www.cnnvd.org.cn/) · [CNCERT/CC](https://www.cert.org.cn/) · [CNVD](https://www.cnvd.org.cn/)
  国内漏洞库与应急组织官网。用在哪：国内通报口径与合规佐证。⚠ CNVD 实测当日返回 521，作为依赖需自备备份路径。

### 国际

- [r/netsec](https://www.reddit.com/r/netsec/) · [r/blueteamsec](https://www.reddit.com/r/blueteamsec/)
  高信噪比、强审核。用在哪：把你的工具/文章丢进去挨批评 —— 这是最快的反馈循环。
- [OWASP Slack（邀请链接）](https://owasp.org/slack/invite) · [ProjectDiscovery Discord](https://discord.gg/projectdiscovery)
  用在哪：项目作者与维护者就在里面，问工具行为与计划最直接。
- [seclists.org](https://seclists.org/) · [oss-security 邮件列表](https://www.openwall.com/lists/oss-security/)
  用在哪：原始披露邮件与讨论，比新闻早且没有转述失真。
- [DEF CON](https://defcon.org/) · [HITB](https://conference.hitb.org/) · [Black Hat](https://www.blackhat.com/)（实测对非浏览器请求返回 403）
  用在哪：看议题与研究方向，判断行业在关心什么。

## Gaps

以下空白已被确认存在，未来搜索应从这些方向切入：

- **中文数据分类分级的公开实操案例几乎没有**：标准只给规则不给样例。项目 3 若做出可复现的示例（哪怕是合成数据），本身就有稀缺价值。
- **缺高质量的中文「安全人做产品」社区**：现有社区偏攻防技术，罕见讨论选型、定价、合规与交付。这可能正是本项目的差异化空间。
- **Web 漏洞的中文一手教学资源薄弱**：多数是英文内容的二手翻译，直接读 PortSwigger 更省时间。
- **用户尚未表态是否愿意加入社区**：本工作区**暂不推荐**任何付费圈子/课程，等用户明确偏好后再补。
- **线下/本地社区未调研**：需要用户所在城市信息，暂缺。
