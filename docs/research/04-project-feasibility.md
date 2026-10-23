# 04 - 候选项目可行性核实

> 核实日期：2026-10-13。所有「免费额度 / 速率限制 / 许可证 / 定价」断言均附一手来源（官方文档、官方定价页、官方仓库 LICENSE）。
> 取不到的写 `[未核实]`。定价与配额会变动，落地前请重新核对。
> 判定口径：「1-3 个晚上做出可用 MVP」= 每晚 3-4h，有开发经验但安全初学的前提下。

## 结论速览

| # | 项目 | 1-3 晚出 MVP | 核心依赖是否免费/可用 | 法律风险 |
|---|------|-------------|---------------------|---------|
| 1 | 漏洞情报日报聚合器 | ✅ 可以（约 2.5 晚） | ✅ 全免费且许可宽松 | 低 |
| 2 | 自有资产攻击面测绘 | ⚠️ 勉强（3 晚，砍到最小） | ✅ 工具全免费/开源 | 中（限自有资产） |
| 3 | 数据资产发现与分类分级 | ⚠️ 可以（中文再加 1 晚） | ✅ Presidio MIT | 中（处理 PII） |
| 4 | 恶意/钓鱼 URL 检测 API | ✅ 容易（1-1.5 晚） | ✅ 但要商业用全部受限 | 低 |
| 5 | 泄露凭据监控 | ❌ 3 晚做不出「可用」 | ❌ 需付费订阅 | 高 |
| 6 | 安全教学靶场 | ✅ 可以（2 晚） | ✅ 全官方 Docker | 低（需隔离） |

**总建议**：先做 **1（情报聚合）**，再做 **6（靶场）** 作为教学产品底座。二者都零法律风险、全依赖免费，且 1 的产物是后续所有项目的「情报底座」。

---

## 项目 1：漏洞情报日报聚合器

**一句话价值**：每天把「正在被利用的漏洞」自动汇成一封可读的日报，省掉人工刷 4 个网站。
**目标用户**：中小企业的运维/安全负责人；以及想学「威胁情报 ETL」的开发者（教学对象）。

### 数据源与依赖（全部已核实）

| 数据源 | 是否需要 Key / 付费 | 许可证 | 一手链接 |
|--------|-------------------|--------|---------|
| CISA KEV（已知被利用漏洞） | 免费、无需 Key，提供 CSV / JSON | **CC0 1.0**（可任意使用） | 目录页 <https://www.cisa.gov/known-exploited-vulnerabilities-catalog> ；JSON <https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json> ；许可证 <https://www.cisa.gov/sites/default/files/licenses/kev/license.txt> |
| NVD API 2.0（CVE 元数据） | **Key 非必需但强烈建议**：无 Key **5 请求 / 滚动 30 秒**，有 Key **50 请求 / 滚动 30 秒** | 公共领域（NIST 出版物），使用时须显示 "This product uses data from the NVD API but is not endorsed or certified by the NVD." | <https://nvd.nist.gov/developers/start-here> |
| FIRST EPSS（利用概率分） | 免费、无需注册 | 官方声明 "freely and openly accessible"，**未提供明确许可证文件 → 许可证 `[未核实]`** | 数据页 <https://www.first.org/epss/data> ；每日 CSV `https://epss.empiricalsecurity.com/epss_scores-current.csv.gz`；API <https://api.first.org/epss/>；历史归档 <https://github.com/empiricalsec/epss_scores> |
| GitHub Advisory（GHSA） | REST `GET /advisories` 为公开端点（文档示例无 Authorization 头）；未认证 **60 请求/小时**，带 PAT **5000 请求/小时** | 数据库 **CC-BY-4.0**（需署名） | 端点文档 <https://docs.github.com/en/rest/security-advisories/global-advisories> ；限流 <https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api> ；许可证 <https://github.com/github/advisory-database> |
| （可选替代）OSV API | 免费、无需 Key、**声明「当前无速率限制」**；HTTP/1.1 响应上限 32MiB | OSV 数据来自多源，逐条看源许可 | <https://google.github.io/osv.dev/api/> |
| IM 推送：Telegram Bot API | 免费 | 官方服务条款 | <https://core.telegram.org/bots/api> |

> 关键核实结论（逐条回答问题）：
> - **NVD API key 是否必需**：不强制，但无 Key 的 5 req/30s 做增量同步基本不够用；申请免费。文档建议每 2 小时增量拉一次并用 `lastModStartDate/EndDate`，脚本 sleep 6 秒。
> - **无限速具体数字**：无 Key 5 req / 30s，有 Key 50 req / 30s（同上链接）。
> - **EPSS 批量下载方式**：**不要用 API 做批量**（官方明说 API 只适合按需小批量查询）；批量用固定 URL 的每日 gz CSV（见上表），历史批量用 GitHub 归档仓库。
> - **GitHub Advisory 是否需认证**：`/advisories` 属公开数据，未认证可用（60/h）；建议带 token 提到 5000/h。

### 最小技术栈

**Python**。理由：这是「工具/分析」类（用户既定分工），核心工作量在拉取、归一化、打分、定时，`httpx` + `feedgen`（生成 RSS）+ 一个 cron 即可；无需前端。

### 1-3 晚 MVP 范围

- **Day 1**：拉 CISA KEV + EPSS 每日 CSV，统一以 `cve` 为 join key，落地 SQLite。
- **Day 2**：NVD 增量（`lastMod` 窗口）+ GHSA 增量（`published`/`updated` 过滤），写入同一张表。
- **Day 3**：打分（规则示例：`KEV=必报`，`EPSS≥0.1 加权`，`CVSS≥9.0 加权`），输出 `out/YYYY-MM-DD.md` + `.json` + `feed.xml`，Telegram 推送一条汇总。

**不做**：不做 NVD 全量历史回填（只做增量）；不做漏洞详情页；不做资产关联（不知道用户资产）；不做多用户/多租户；不做邮件 HTML 模板（先纯文本 + Markdown）；不做实时（每天一次即可）；不做付费源的接入。

### 验收标准（可观察）

1. 运行一次命令，`out/` 下同时生成 `.md`、`.json`、`.xml` 三个文件。
2. 同一个 CVE 跨源（NVD/KEV/GHSA）只出现 **1** 条记录（GHSA 通过 `identifiers` 里的 `CVE` 值归并）。
3. Telegram 收到 1 条消息，链接可点。
4. **幂等**：同一天重复运行，已推送过的 KEV 不重复推送（用 `pushed` 表去重）。
5. 日报里每条都带：CVE 号、KEV 是否在列、EPSS 分数、CVSS、一句话描述。

### 风险与合规红线

- NVD：必须显示官方要求的免责声明；不得用 NVD 名称暗示官方背书。
- GitHub Advisory（CC-BY-4.0）、GHSA 数据须**署名**。
- 严守速率限制，做退避（backoff）与本地缓存，别把免费源打挂。
- 不存储任何个人数据，本项目风险最低。

### 变教学内容时的切入点

- 「漏洞优先级」三件套对比：CVSS（严重度）vs EPSS（被利用概率）vs KEV（已确认被利用）——这是安全圈最高频的认知题。
- 「多源情报 ETL」：join key 选择、去重、速率限制与退避、幂等推送。
- 出题：让学生给 EPSS+KEV 设计一个评分函数并解释权重。

---

## 项目 2：自有资产攻击面测绘 + 变更告警

**一句话价值**：给「自己的域名」做影子资产台账，域名/端口/证书一变就告警。
**目标用户**：只有少量自有域名的中小企业；以及学「被动 vs 主动侦察」的学生。

### 数据源与依赖（全部已核实）

| 环节 | 工具/源 | 免费？ | 许可证 | 一手链接 |
|------|--------|-------|--------|---------|
| 子域（CT 日志查询） | crt.sh | 免费、无需 Key（Sectigo 运营） | 站点源码仓库 GPL-3.0 | <https://crt.sh/> ；组织仓库 <https://github.com/crtsh> |
| 子域（实时流） | CertStream Server（自建） | 免费，但**需自建**（Elixir 服务） | **MIT** | <https://github.com/CaliDog/certstream-server> |
| 子域（多源聚合） | subfinder | 免费（自建二进制） | **MIT** | <https://github.com/projectdiscovery/subfinder> |
| 存活探测 / 指纹 | httpx | 免费（自建） | **MIT** | <https://github.com/projectdiscovery/httpx> |
| 端口扫描 | naabu | 免费（自建） | **MIT** | <https://github.com/projectdiscovery/naabu> |
| 端口扫描（可选） | nmap | 免费自用 | **NPSL**（基于 GPLv2 但不同；**禁止**嵌进商业产品再分发） | <https://nmap.org/book/man-legal.html> |

> 关键核实结论：
> - **哪些能纯 API 免费做**：CT 日志查询（crt.sh）可纯 HTTP 拉取；证书本身是公开数据。
> - **哪些必须自建/本机**：存活探测（httpx）、端口扫描（naabu/nmap）、实时 CT 流（CertStream）都得自己发起或自建服务——它们不是「别人托管的 API」，而是你在扫描。
> - crt.sh **无公开的速率限制文档 → 具体阈值 `[未核实]`**，实测会限流/短暂 502，必须做退避与缓存。
> - CertStream 公共实例稳定性无 SLA，建议自建（MIT 可自建）。

### 最小技术栈

**Python**。理由：工具/分析类，`asyncio + httpx` 并发探测、`PyYAML` 读资产清单、SQLite 存快照；调 subfinder/httpx/naabu 用子进程即可。

### 1-3 晚 MVP 范围

- **Day 1**：读 `assets.yaml`（只列**自有**域名）→ crt.sh 拉子域 → 去重。
- **Day 2**：httpx 存活探测（标题、状态码、技术指纹、证书 `not_after`）→ 存 SQLite；naabu 只扫少量常见端口（80/443/8080/8443）。
- **Day 3**：与上一次快照 diff（新增/消失子域、端口变化、证书变更）→ 输出 `diff.md`。

**不做**：不做漏洞扫描/利用（nuclei 等一律不进 MVP）；不做第三方/客户资产；不做大网段全端口扫描；不做分布式扫描节点；不做 UI；不做资产打标（手动确认归属）。

### 验收标准（可观察）

1. 对自有域名跑一次，产出 `snapshot.json` 与 `diff.md`。
2. 第二次运行且环境无变化时，`diff.md` 明确显示「无变化」。
3. 新开一个子域后重跑，`diff.md` 标出该新增子域。
4. 报告含每个 host 的证书到期日。

### 风险与合规红线（本项目最需要写清楚）

- **只扫自有/已书面授权资产**。对第三方做端口扫描/探测，在多数司法辖区可能落进「未经授权访问计算机系统」（中国《刑法》第 285/286 条、《网络安全法》；美国 CFAA）。MVP 里应有显式「授权声明」字段，未填不得运行。
- 遵守目标站点 `robots`/WAF 策略，控制并发，别把对方打挂。
- 建议在 `assets.yaml` 顶部强制写：`# 我声明对以下资产拥有或获得书面授权`。

### 变教学内容时的切入点

- CT 日志（Certificate Transparency）原理与「证书透明度为什么能暴露影子资产」。
- 被动侦察 vs 主动侦察的边界，以及「授权范围」为什么是安全工作的第一条。
- 资产台账与影子资产治理（企业资产安全的核心问题）。

---

## 项目 3：数据资产发现与分类分级 MVP

**一句话价值**：给一份表格/库表清单，自动标出哪些列是 PII 并定级。
**目标用户**：要做数据合规/数据安全治理的企业；数据工程师转安全的学习者。

### 数据源与依赖（全部已核实）

| 依赖 | 是否需要 Key / 付费 | 许可证 | 一手链接 |
|------|-------------------|--------|---------|
| Microsoft Presidio（PII 识别/脱敏框架） | 免费（本地 SDK） | **MIT** | 仓库已迁移至 <https://github.com/data-privacy-stack/presidio> ；LICENSE <https://raw.githubusercontent.com/microsoft/presidio/main/LICENSE> |
| Presidio 多语言能力 | 免费（需自配模型） | — | <https://data-privacy-stack.github.io/presidio/analyzer/languages/> |
| Stanza（Stanford NLP，含中文模型） | 免费 | **Apache-2.0** | <https://github.com/stanfordnlp/stanza> |
| spaCy | 免费 | **MIT** | <https://github.com/explosion/spaCy> |
| HanLP（中文 NLP） | 免费 | **Apache-2.0** | <https://github.com/hankcs/HanLP> |

> 关键核实结论：
> - **Presidio 许可证**：MIT（已核对 LICENSE 文本）。注意仓库已从 `microsoft/presidio` **迁移到 `data-privacy-stack/presidio`**（旧地址跳转）。
> - **中文能力**：**开箱只有英文**。官方文档原文：「In its default configuration, it contains recognizers and models for English.」要支持中文需替换 `NlpEngine` 的中文模型并改写识别器的 context words。→ **中文是额外工作量（约 +1 晚）**。
> - **替代方案**：开源里 Presidio 是最主流的（无更省事的开源平替）；商业方案（Google Cloud Sensitive Data Protection、AWS Macie）按量付费，**定价未在本轮核实 → `[未核实]`**。

### 最小技术栈

**必须 Python**。理由：Presidio 是 Python SDK（`presidio-analyzer`/`presidio-anonymizer`），配合 `pandas` / `SQLAlchemy` 读 CSV 与本地库。

### 1-3 晚 MVP 范围

- **Day 1**：`classify.py --input data.csv --config rules.yaml`：正则识别（邮箱/手机号/身份证/银行卡）+ Presidio 英文识别器 → 列级判定。
- **Day 2**：规则引擎定级（示意：`L1 公开 / L2 内部 / L3 敏感 / L4 核心`；例：命中身份证/手机号 → L3+）→ 写 `catalog.json`（表.列 → 类型 / 级别 / 命中数）。
- **Day 3**：生成 `report.md`（含「未识别为 PII 的列」清单，避免假阴性被忽略）。

**不做**：不连生产库（只接受导出 CSV / 本地 SQLite）；不扫海量非结构化文本；不做中文 NER 深度调优（先用正则兜底）；**只报告不改写**（脱敏动作放 v2）；不接对象存储清单；不落盘原始敏感值（只留计数/哈希）。

### 验收标准（可观察）

1. 输入一份含中英文字段的 CSV，输出 `catalog.json`，**每一列**都有判定（PII 类型或「非 PII」）。
2. 含身份证/手机号的列被标为 L3 及以上。
3. 报告里能列出「疑似漏判」的列供人工复核。
4. 原始敏感值不出现在任何输出文件中（只出现计数与哈希）。

### 风险与合规红线

- 处理他人 PII 触发《个人信息保护法》/GDPR 义务。**MVP 只用自造或脱敏样例数据**。
- 不落地明文敏感值；日志中不打印原始值。
- 分级标准：可结合国内数据分类分级相关标准/行业规范，**具体标准号本轮未核实 → `[未核实]`**，落地时请核对。

### 变教学内容时的切入点

- 正则 vs NER vs 校验位（身份证/银行卡 checksum）的取舍：为什么「检测」永远有假阳/假阴。
- 数据分类分级方法论与企业数据资产盘点流程（切中「企业数据资产安全」方向）。
- 用 `k-anonymity`/掩码讲隐私工程。

---

## 项目 4：恶意/钓鱼 URL 检测 API

**一句话价值**：给一个 URL，判断它是不是已知钓鱼/恶意，并列出命中的情报源。
**目标用户**：做内部小工具的安全团队；想学「威胁情报聚合」的学生。

### 现有免费信号源（全部已核实）

| 信号源 | 免费额度 / 是否需要 Key | 关键限制 | 一手链接 |
|--------|----------------------|---------|---------|
| Google Safe Browsing API v4（Lookup） | 免费，需 API Key；**默认配额未公开数字，需在 Console 查看 → 配额数值 `[未核实]`**；单请求最多 500 个 URL | **仅限非商业用途**；商业须改用 Web Risk。用其警告须含限定语并署名 "Advisory provided by Google" | <https://developers.google.com/safe-browsing/v4/usage-limits> ；Lookup 用法 <https://developers.google.com/safe-browsing/v4/lookup-api> ；v5 参考 <https://developers.google.com/safe-browsing/reference/rest> |
| PhishTank（Cisco Talos 运营，**仍在运营**） | 免费；自动抓取建议注册免费 app key（无 key 每天仅少量下载） | 数据**每小时**更新；已验证在线钓鱼库 | <https://phishtank.org/developer_info.php> ；API <https://phishtank.org/api_info.php> ；数据 `http://data.phishtank.com/data/online-valid.json.gz` |
| OpenPhish 社区 feed | 免费，**12 小时**更新，纯文本 | **仅非商业/个人研究**；任何商业用途（含 enrichment/产品开发/SOC）需书面许可 | <https://openphish.com/phishing_feeds.html> ；条款 <https://openphish.com/terms.html>；feed <https://raw.githubusercontent.com/openphish/public_feed/refs/heads/main/feed.txt> |
| URLhaus（abuse.ch） | 免费，**需免费 Auth-Key** | recent 查询只返回近 3 天且最多 1000 条 | <https://urlhaus-api.abuse.ch/> ；Key 申请 <https://auth.abuse.ch/> |
| Cloudflare Radar API | 免费，但**需 Cloudflare API Token**（Account > Radar > Read） | 数据许可 **CC BY-NC 4.0（非商业）** | <https://developers.cloudflare.com/radar/> ；取 Token <https://developers.cloudflare.com/radar/get-started/first-request/> |
| VirusTotal 公共 API | 免费，需注册 Key | **500 请求/天 + 4 请求/分钟**；**禁止商业用途**；禁止用于不贡献新文件的业务流；禁止多账号绕过 | <https://docs.virustotal.com/reference/public-vs-premium-api> |

### 为什么它能做小、做不大

- **所有免费源都写了「非商业」**（Safe Browsing、OpenPhish、Cloudflare Radar、VirusTotal 均如此）。想商业化就要买 Web Risk / OpenPhish Premium / VT Premium——**免费额度决定了它只能是内部工具或教学样例，做不成付费 API 产品**。
- 技术本质是「拉 feed + 去重 + 查表」，护城河极低；别人一夜能复制。
- 检测必然有误报，对外提供服务就要承担声誉与免责成本。
- 真正值钱的是**独有数据**（自建爬虫/蜜罐），不是「聚合免费 API」。

### 最小技术栈

**Python**。理由：feed 拉取、归一化、规则匹配用 Python 最省事；只在需要对外暴露 HTTP 时才考虑 TS（Fastify），MVP 不需要。

### 1-3 晚 MVP 范围

- **Day 1**：`update_feeds.py` 拉 OpenPhish + URLhaus + PhishTank 快照到本地 SQLite，去重。
- **Day 2**：`check.py <url>` 返回 `{verdict, score, sources[], cached_at}`；可选接入 Safe Browsing Lookup 做二次确认（带缓存）。

**不做**：不做实时全量订阅（定时更新即可）；不做页面内容分析/截图；**不做 VT 全量查询**（配额太小，仅按需单查 + 缓存）；不做商业化方向；不做浏览器插件/前端。

### 验收标准（可观察）

1. 给 10 个**已知来自 feed** 的恶意 URL，全部返回 `hit` 且列出来源。
2. 给 10 个正常 URL（如 `google.com`）返回 `clean`。
3. 每个结果带来源与数据时间戳（缓存时间）。
4. 重复查询同一 URL 命中本地缓存，不再打外部 API。

### 风险与合规红线

- **免费源的非商业条款是硬红线**：用于教学/个人研究可以，用于公司产品要先拿到许可。
- 使用 Safe Browsing 的警告文案必须用限定语（suspected/possibly）并署名 Google。
- 不得缓存/转发源数据中可能包含的用户隐私。
- 误报要显式标注「疑似」，不能下断言。

### 变教学内容时的切入点

- 威胁情报聚合的去重与置信度融合（多源投票、时间衰减）。
- 「为什么免费 API 拼不出商业产品」——讲清数据授权与护城河，这是一节很值钱的商业认知课。
- URL 短链/Punycode 同形异义攻击等钓鱼手法。

---

## 项目 5：泄露凭据监控

**一句话价值**：监控自有域名/员工邮箱是否出现在泄露事件中。
**目标用户**：有合规与安全预算的企业；**不适合个人学习者做产品**。

### 现有服务与定价（全部已核实）

| 服务 | 是否需付费 | 现行定价（官方） | 一手链接 |
|------|----------|----------------|---------|
| Have I Been Pwned（HIBP） | 邮件/域名查询**需付费订阅 Key**；Pwned Passwords 免费 | Core 从 **$4.39/月** 起（10 RPM，1 域名）；Pro 从 **$379/月**；High RPM 从 **$1,150/月**；企业版无限速 | API 文档 <https://haveibeenpwned.com/API/v3> ；定价 <https://haveibeenpwned.com/Subscription> ；免费 Pwned Passwords 见 API 文档 `#PwnedPasswords` |
| DeHashed | 付费（订阅 + credits） | **定价页为动态渲染，本轮未取到固定数字 → `[未核实]`**；官网称政府/非营利可免费 | <https://dehashed.com/api> |
| LeakCheck | 有免费 Public API（仅返回「是否命中」，不返回数据）；付费解锁 | Basic **$2.99/天**（15 查询）；Monthly **$9.99/月**（200/天，API 3 RPS）；Lifetime **$69.99**；Enterprise **from $179/季** | <https://leakcheck.io/pricing> |

> 关键核实：
> - **HIBP 无免费邮件查询**：邮件/域名查询必须带订阅 Key；唯一免费的是 Pwned Passwords（k-anonymity）。API 文档明确指出「There is no authorisation required for the free Pwned Passwords API」。
> - HIBP 的**域名监控有所有权门槛**：必须证明你拥有/控制该域名；且 **Core 条款不允许代第三方监控，MSP 必须用 Pro**。
> - **合规红线**：查询他人邮箱/凭据属于处理个人数据（《个人信息保护法》/GDPR 需合法依据）；**不得下载或存储明文密码**。

### 最小技术栈

**Python**（调度 + API 客户端 + 报告）。若将来要做企业多租户面板再加 TS。

### 是否 1-3 晚能出「可用 MVP」

**不能。** 理由（这是本项目的核心结论）：
1. 「可用」的前提是能查真实邮箱/域名 → **必须先付费**（Core $4.39/月起）或申请企业评估。
2. 真正有价值的是「持续监控 + 告警」，需要域名所有权验证、订阅配额管理、凭据不出本地等工程。
3. 3 晚内只能做出「用 test key 跑通文档示例」的 demo，不是可用产品。

### 若仍要做的 MVP 范围（作为教学 demo）

- 输入：自有域名 + 员工邮箱清单（**自造样例**）。
- 用 HIBP test key（`000...`，仅能查 `hibp-integration-tests.com` 测试邮箱）跑通 `breachedAccount`。
- Pwned Passwords：本地算 SHA-1 前缀，走 k-anonymity 查询，判断某密码是否泄露（**不发送明文**）。

**不做**：不存储明文密码；不查询非授权邮箱；**不做暗网爬虫/数据采集**（法律风险极高）；不做撞库/凭据填充；不批量下载 HIBP 全量哈希以外的任何数据集。

### 验收标准（可观察）

1. 用 test API key 走通官方示例（`account-exists@hibp-integration-tests.com`）。
2. Pwned Passwords 查询：本地生成 SHA-1 前缀 → 命中返回泄露次数，全程不上传明文。
3. 报告只显示「邮箱 + 命中的 breach 名称」，**不含任何密码**。

### 风险与合规红线

- 本项目合规风险最高：合法基础、最小必要、目的限制。
- 用 k-anonymity 降低对第三方的数据暴露。
- 只监控自有/已获授权域名（HIBP 条款强制所有权验证）。
- **绝不协助账号接管（ATO）**。

### 变教学内容时的切入点

- HIBP 的 k-anonymity 设计（为什么它敢公开、又怎么保护隐私）——非常好的隐私工程案例课。
- 泄露数据生态与合规边界：为什么「帮你查别人的密码」是红线。

---

## 项目 6：安全教学靶场 / 实验环境

**一句话价值**：一套可离线运行、有明确通关标准的靶场，是教学产品的底座。
**目标用户**：安全入门学生；教师/课程作者（你自己）。

### 靶场依赖（全部已核实）

| 靶场 | 官方 Docker / 离线可跑 | 许可证 | 一手链接 |
|------|---------------------|--------|---------|
| OWASP Juice Shop | ✅ 官方镜像 `bkimminich/juice-shop`，本地 `docker run` 即可 | **MIT**（官方配套书为 **CC BY-NC-ND 4.0，非商用**） | 仓库 <https://github.com/juice-shop/juice-shop> ；官方站点 <https://owasp-juice.shop> |
| DVWA | ✅ 官方 `Dockerfile` + `compose.yml` | **GPL-3.0** | <https://github.com/digininja/DVWA> |
| Vulnerable-AD | ⚠️ **非纯 Docker**：需自建 Windows 域控，跑 PowerShell 脚本 | **MIT** | <https://github.com/safebuffer/vulnerable-AD> |
| Kubernetes Goat | ✅ Docker/K8s 场景 | **MIT** | <https://github.com/madhuakula/kubernetes-goat> |
| （AD 替代）GOAD | ✅ Terraform/Ansible 多机编排 | **GPL-3.0** | <https://github.com/Orange-Cyberdefense/GOAD> |

> 关键核实：
> - Juice Shop / DVWA / K8s Goat **都能完全离线跑**（Docker 镜像拉到本地）。
> - **Vulnerable-AD 不能纯 Docker 跑**：它是要你在**自己的 Windows 域控**上执行的 PowerShell 脚本，成本高，建议排到 v2。
> - **许可证差异影响课程**：MIT（Juice Shop / K8s Goat / Vulnerable-AD）最宽松；GPL-3.0（DVWA / GOAD）改动用可，但要开源衍生；Juice Shop 官方**配套电子书**是 CC BY-NC-ND 4.0，**不能商用**——自制课程要注意别直接搬官方书内容。

### 做成课程的成本评估

- **环境**：低（Docker compose，一晚能跑通两个靶场）。
- **内容**：中（每关要写「目标 / 提示 / 验收」，写清楚一关约 1-2h）。
- **判分**：中（自动判分脚本是真正拉开质量的地方）。
- **建议 MVP 覆盖 3-5 关**，先验证「环境 + 任务 + 判分」这套模式能跑通。

### 最小技术栈

靶场本身不限语言；**课程自动化判分用 Python**（`requests` 打靶场 + `pytest` 断言「是否达成」），环境用 **Docker Compose**。

### 1-3 晚 MVP 范围

- **Day 1**：`docker-compose.yml` 起 Juice Shop + DVWA；写好「环境启动 / 重置」说明。
- **Day 2**：实验手册（Markdown）：3 个任务（如 Juice Shop 登录 SQLi、DVWA XSS、DVWA 命令注入），每个任务写清「目标 → 提示 → 完成标准」。
- **Day 3**：`verify.py` 自动判分（如 curl 检查是否拿到 admin token / 是否触发 XSS 弹窗），跑通端到端。

**不做**：不做视频课程（先文字）；不做云托管环境（本地 Docker）；不覆盖全部关卡；不做 Vulnerable-AD（需 Windows 域控，成本高，放 v2）；不教攻击工具链（Metasploit 等）。

### 验收标准（可观察）

1. `docker compose up` 后两个靶场在本地可访问。
2. 有新机器按手册照做，30 分钟内能完成第 1 关。
3. `verify.py` 能对每关给出「通过 / 未通过」的客观判定。
4. 靶场仅监听 `127.0.0.1`，不外网暴露。

### 风险与合规红线

- 靶场**必须隔离**（NAT / 仅本地回环），DVWA 官方 README 明确警告不要放到公网。
- 课程需免责声明；不得把靶场用于真实攻击。
- 若做**商业**课程：Juice Shop 官方书是 CC BY-NC-ND，**不能商用**；DVWA 是 GPL-3.0，改动衍生需开源。自制内容不受此限。

### 变教学内容时的切入点

这**本身就是**教学产品底座。方法论：把一门安全课拆成「**环境 + 任务 + 判分**」三件套。一旦这套跑通，可复制到其他主题（云安全、数据安全、应急响应）。

---

## 总表

| 项目 | 技术栈 | 实现难度 (1-5) | 学习收益 | 复用价值 | 法律风险 | 推荐顺序 |
|------|--------|:------------:|:-------:|:-------:|:-------:|:-------:|
| 1 漏洞情报日报聚合器 | Python | **3** | 高（ETL/情报/评分） | **高**（情报底座） | 低 | **1** |
| 6 安全教学靶场 | Docker + Python | **1** | 中（实操） | **高**（教学底座） | 低 | **2** |
| 3 数据资产分类分级 | Python（必须） | **3**（中文 **4**） | 高（数据安全） | 高 | 中 | **3** |
| 2 攻击面测绘（自有） | Python | **4** | **高**（侦察/CT/资产） | 中 | 中 | **4** |
| 4 恶意/钓鱼 URL 检测 | Python（API 时 TS） | **2** | 中（情报聚合） | 低（免费源禁商用） | 低 | **5** |
| 5 泄露凭据监控 | Python | **4** | 中（但被合规主导） | 低（需付费订阅） | **高** | **6** |

### 推荐顺序的理由

1. **项目 1 排第一**：所有依赖**免费且许可宽松**（CC0 / 公共领域 / MIT / CC-BY-4.0），零法律风险，2-3 晚可成，且产出的情报管道是所有后续产品都能复用的「底座」。
2. **项目 6 排第二**：难度最低、依赖全官方 Docker，是「教学/课程产品」这一既定方向最快的落地物；把它做完就有了可复制的课程生产模式。
3. **项目 3 排第三**：Presidio 是 MIT、企业数据资产安全又是既定方向；但中文需额外接模型，所以排在有把握之后做，预留加班。
4. **项目 2 排第四**：技术学习收益最高（CT 日志、被动 vs 主动侦察、资产台账），但**主动扫描有法律边界**，必须限定自有资产，风险高于前三。
5. **项目 4 排第五**：技术上最容易，但**免费信号源全部禁止商业用途**，产品天花板低——适合当教学案例，不适合投入做产品。
6. **项目 5 排末位**：合规风险最高、且「可用 MVP」**必须付费订阅**（HIBP Core $4.39/月起），3 晚内出不了可用产品；要做也只建议做成教学 demo。

### 全局合规红线（适用于全部项目）

- **只对自有或已获书面授权的资产做任何主动操作**（扫描/探测/枚举）。
- **区分「公开数据」与「他人数据」**：CT 日志、漏洞库是公开数据；泄露库、邮箱、密码属个人数据，处理即触发 PIPL/GDPR。
- **免费情报源的非商业条款**是产品化的第一道门槛，做产品前逐条读许可。
- 主动扫描类项目在配置里强制写「授权声明」，未填不得运行。
