# 安全资讯 / 威胁情报能力：必须掌握的知识与数据源

> 核实时间：2026-10-13（所有版本号、额度、可用性断言均在当日用官方页面 / 官方 API 现场核实；核实不到的标 `[未核实]`）。
> 可编程性评级：★★★ = 有官方稳定 API/Feed；★★ = 有非官方或不稳定接口/流；★ = 只能网页抓取或人工查看。

---

## 0. 结论摘要

做「安全资讯 / 威胁情报」工具，**不需要先自建爬虫**。有一批官方、免费、可编程的一手源（CISA KEV、NVD、EPSS、OSV、GHSA、ATT&CK、CWE）已经把「漏洞 + 利用状态 + 概率」三件事覆盖掉了。真正的工作量在第二层：**归一化、去重、打分排序**（见 §5），以及判断力（见 §4）。抓中文资讯源只解决「资讯」那一半，且大多没有 API。

| 数据源 | 端点 | 需要 key | 额度 / 限速 | 格式 | 许可证 | 评级 |
|---|---|---|---|---|---|---|
| CISA KEV | 见 §1.1 | 否 | 静态文件，无限速 | JSON / CSV | CC0 1.0 | ★★★ |
| NVD API 2.0 | 见 §1.2 | 否（有 key 更快） | 无 key 5 req/30s；有 key 50 req/30s | JSON | 美国公域（须署名声明） | ★★★ |
| FIRST EPSS | 见 §1.3 | 否 | 无注册；API 定位 lookup，批量用 CSV | JSON / CSV.gz | 免费公开 | ★★★ |
| GHSA（GitHub Advisory） | 见 §1.4 | 是（token） | 未认证 60/h；认证 5000/h | JSON | 数据库 CC-BY 4.0 | ★★★ |
| OSV.dev | 见 §1.5 | 否 | 官方称无限制 | JSON + GCS dump | 见各源 | ★★★ |
| MITRE ATT&CK | 见 §1.6 | 否 | 静态 + TAXII | STIX 2.1 / TAXII 2.1 | 见仓库 | ★★★ |
| CWE | 见 §1.7 | 否 | REST API + XML | JSON / XML / CSV | 见站点 | ★★★ |
| CVSS v4.0 / v3.1 | 见 §1.8 | 否 | 规范文档，非 feed | 文档 + 公式 | 见站点 | ★★★（规范） |
| Exploit-DB | 见 §1.9 | 否 | git clone / CSV | CSV | 见仓库 | ★★ |
| Metasploit | 见 §1.9 | 否 | RPC（本地起服务） | JSON-RPC | BSD 类 | ★★ |
| crt.sh | 见 §1.10 | 否 | 无文档化 API，实测不稳定 | 网页 / 非官方 JSON | 见站点 | ★ |
| CertStream | 见 §1.10 | 否 | WebSocket 实时流，无 SLA | JSON over WS | 服务端 MIT | ★★ |

---

## 1. 可编程的一手情报源

### 1.1 CISA KEV（Known Exploited Vulnerabilities）

- 目录页：<https://www.cisa.gov/known-exploited-vulnerabilities-catalog>
- **JSON feed**：<https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json>
- **CSV**：<https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv>
- JSON Schema：<https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities_schema.json>
- 许可证：**CC0 1.0**，原文见 <https://www.cisa.gov/sites/default/files/licenses/kev/license.txt>（"The KEV database is distributed under the Creative Commons 0 1.0 License."）
- 镜像仓库：<https://github.com/cisagov/kev-data>
- **需要 key：否。速率限制：静态文件，无公开限速。格式：JSON / CSV（另提供打印视图）。**

实测（2026-10-13）：JSON 返回 `catalogVersion: 2026.10.08`、`dateReleased: 2026-10-08T20:09:18.9833Z`、`count: 1739`；CSV 为 `200 text/csv`，约 1.05 MB。字段含 `cveID / vendorProject / product / vulnerabilityName / dateAdded / shortDescription / requiredAction / dueDate / knownRansomwareCampaignUse / notes`。

> 用途：KEV 是「已被在野利用」的**权威确证清单**，是漏洞优先级里权重最高的一路信号（NVD 自己也把 KEV 作为最高优先级富化对象，见 §1.2）。

### 1.2 NVD API 2.0

- API 文档（漏洞）：<https://nvd.nist.gov/developers/vulnerabilities>
- Base URL：`https://services.nvd.nist.gov/rest/json/cves/2.0`
- 快速上手 / 限速官方说明：<https://nvd.nist.gov/developers/start-here>
- 申请 API key：<https://nvd.nist.gov/developers/request-an-api-key>
- 状态标签说明：<https://nvd.nist.gov/vuln/vulnerability-status>
- 实时看板：<https://nvd.nist.gov/general/nvd-dashboard>
- CVE 处理流程：<https://nvd.nist.gov/general/cve-process>

**需要 key：否（可匿名用，只是慢）；想要高限速需免费申请 key。**
限速官方原文（<https://nvd.nist.gov/developers/start-here>）：
> "The public rate limit (without an API key) is **5 requests in a rolling 30 second window**; the rate limit with an API key is **50 requests in a rolling 30 second window**."

许可证 / 使用条款：NIST 出版物属美国公域，但要求在使用 NVD 的应用中显著展示声明：**"This product uses data from the NVD API but is not endorsed or certified by the NVD."**（同 `start-here` 页）。

**富化延迟 / 积压的官方说明（关键，直接决定架构）**——NIST 官方公告页 <https://www.nist.gov/itl/nvd>：

- "Starting in early 2024, the NVD developed a significant backlog of unenriched CVEs. Unfortunately, we have been unable to clear that backlog, in part due to the increasing rate of submissions."
- 自 **2026-04-15** 起 NVD 按新优先级富化：① 在 CISA KEV 中的 CVE（目标：收到后 1 个工作日内富化）；② 联邦政府使用的软件；③ 依 EO 14028 定义的 critical software。不满足者标记为 **"Lowest Priority - not scheduled for immediate enrichment"**。
- 发布日早于 **2026-03-01** 的积压 CVE 统一移入 **"Not Scheduled"** 类别。
- NIST 不再对所有 CVE 例行提供自己独立的 severity score（改为按需申请）。

**NVD 上 CVSS v4.0 的覆盖（实测）**：API 接受 `cvssV4Severity` 参数（请求成功、但返回 `totalResults: 0`）；实测 `CVE-2025-21418`、`CVE-2024-47176`、`CVE-2025-1094` 都只返回 `cvssMetricV31`。**结论：NVD 当前仍以 CVSS v3.1 数据为主，不要把「NVD 有 v4.0」当成默认假设。**

> 工程含义：**永远不要把「NVD 还没富化」等同于「漏洞不重要」**。NVD 只保证 CVE 记录本身入库，富化是尽力而为。所以聚合器必须能脱离 NVD，直接用 KEV + EPSS + OSV/GHSA 生效。

### 1.3 FIRST EPSS（Exploit Prediction Scoring System）

- 项目首页：<https://www.first.org/epss/>
- **API 文档**：<https://api.first.org/epss/>（Base：`https://api.first.org/data/v1/epss`）
- 数据获取页：<https://www.first.org/epss/data>
- **每日 CSV（单一稳定 URL）**：<https://epss.empiricalsecurity.com/epss_scores-current.csv.gz>
- 历史归档仓库：<https://github.com/empiricalsec/epss_scores>

**需要 key：否，无需注册。** 官方定位：API 用于**单条 / 小批量 lookup**，"should not be used for bulk downloads"；要全量同步必须用每日 CSV 或 GitHub 仓库（<https://www.first.org/epss/data>）。
输出语义：**未来 30 天内该 CVE 被利用的概率（0–1）+ percentile 排名**（<https://www.first.org/epss/>）。
许可证：free of charge, no registration（同数据页）。

**模型版本（实测 + 官方版本历史）**：

- 实测当前 CSV 首行：`#model_version:v2026.06.15,score_date:2026-10-12T12:00:26Z`
- 即**当前模型为 EPSS v5（v2026.06.15），自 2026-06-15 起发布**。
- 版本历史（<https://www.first.org/epss/data>）：v1 起 2021-04-14；v2（v2022.01.01）2022-02-04；v3（v2023.03.01）2023-03-07；v4（v2025.03.14）2025-03-17；v5（v2026.06.15）2026-06-15。
- CSV 三列：`cve, epss, percentile`。

> 注意：API 响应里的 `"version": "1.0"` 是 **API 版本**，不是 EPSS 模型版本（官方在数据页明确提示 "the 'v1' in the URL is a reference to the API version, not the EPSS version"）。

### 1.4 GitHub Security Advisory（GHSA）

- REST 文档：<https://docs.github.com/en/rest/security-advisories/global-advisories>
- 端点：`GET /advisories`（可分页，`per_page` 最大 100，`sort` 支持 `updated` / `published` / `epss_percentage` / `epss_percentile`）
- 数据库仓库（可直接 clone）：<https://github.com/github/advisory-database>
- 速率限制官方页：<https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api>

**需要 key：生产必须要 token。** 官方文档示例普遍要求 `Authorization: Bearer <YOUR-TOKEN>`；未认证请求按 IP 限制 **60 requests/hour**，认证后 **5000 requests/hour**（<https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api>）。实测本机无 token 请求 `api.github.com/advisories` 返回 `403`，因此不要依赖匿名调用。
许可证：`advisory-database` 仓库为 **CC-BY 4.0**（实测 `LICENSE.md` 正文为 "Attribution 4.0 International"）。

### 1.5 OSV.dev

- API 文档：<https://google.github.io/osv.dev/api/>
- 单条查询：`GET https://api.osv.dev/v1/vulns/{id}`（实测 `https://api.osv.dev/v1/vulns/OSV-2020-111` 返回 JSON）
- 批量查询：`POST https://api.osv.dev/v1/querybatch`（实测无需 key 即返回结果）
- 全量数据 dump：<https://google.github.io/osv.dev/data/> → GCS 桶 <https://storage.googleapis.com/osv-vulnerabilities/index.html>（`all.zip`）

**需要 key：否。** 官方原文："**Currently there are no limits on the API**"；HTTP/1.1 下单次响应上限 32 MiB，HTTP/2 无限制（<https://google.github.io/osv.dev/api/>）。格式：JSON（OSV schema）。许可证：随各上游源，详见 <https://google.github.io/osv.dev/data/>。

> OSV 的价值：覆盖**开源生态的包级漏洞**（PyPI / npm / Go / Debian…），并且大量记录带 GHSA / CVE 别名，是做「依赖漏洞」场景的首选 API。

### 1.6 MITRE ATT&CK

- 版本历史：<https://attack.mitre.org/resources/versions/> → 官方标注 **Current Version: ATT&CK v19.2**
- 更新说明：<https://attack.mitre.org/resources/updates/> → v19.2（2026-08-06，首个 Agile 窄范围发布），v19（2026-04）
- 数据与工具页：<https://attack.mitre.org/resources/attack-data-and-tools/>
- **STIX 2.1 数据仓库**：<https://github.com/mitre-attack/attack-stix-data>
  - Enterprise bundle 直链：<https://raw.githubusercontent.com/mitre-attack/attack-stix-data/master/enterprise-attack/enterprise-attack.json>（实测 HTTP 200）
  - 版本索引：<https://raw.githubusercontent.com/mitre-attack/attack-stix-data/master/index.json>
- **TAXII 2.1 官方服务**：<https://attack-taxii.mitre.org/taxii2/>
  - 必须带请求头 `Accept: application/taxii+json;version=2.1`（实测返回 `api_roots: ["/api/v21", ...]`）
  - Collections：<https://attack-taxii.mitre.org/api/v21/collections/>（实测返回 Enterprise / ICS / Mobile ATT&CK）
- Python 工具：<https://github.com/mitre-attack/mitreattack-python/>

**需要 key：否。** 格式：STIX 2.1 bundle / TAXII 2.1 collection。许可证：见各仓库（`attack-stix-data`）。

### 1.7 CWE

- 当前版本 **4.20**：<https://cwe.mitre.org/data/index.html>（页面标题即 "CWE List Version 4.20"）
- 下载页：<https://cwe.mitre.org/data/downloads.html>（XML ZIP：<https://cwe.mitre.org/data/xml/cwec_latest.xml.zip>；另有 CSV / XSD）
- **REST API**：`https://cwe-api.mitre.org/api/v1/cwe/weakness/{id}`（实测 `https://cwe-api.mitre.org/api/v1/cwe/weakness/79` 返回 JSON）

**需要 key：否（实测直接可用）。速率限制：官方未公开 [未核实]。格式：JSON / XML / CSV。**

### 1.8 CVSS v4.0 与 v3.1 的关系

- CVSS SIG 官方页：<https://www.first.org/cvss/> —— 原文："**CVSS is currently at version 4.0**"，v4.0 初始版本发布于 **2023 年 11 月**。
- CVSS v4.0 规范：<https://www.first.org/cvss/v4.0/specification-document>
- User Guide：<https://www.first.org/cvss/v4.0/user-guide>；FAQ：<https://www.first.org/cvss/v4.0/faq>
- CVSS v3.1 规范（**仍然存在、仍被大规模使用**）：<https://www.first.org/cvss/v3.1/specification-document>

**关系**：v4.0 是新一代评分体系；v3.1 并未作废。二者**不是简单数值换算关系**（v4.0 引入了 Attack Requirements、多个影响子分数、Threat/Environmental 新指标），不同版本分数不能直接互比。实测 NVD 上主流 CVE 仍只有 v3.1（见 §1.2），所以聚合器必须**同时容纳 v3.1 与 v4.0 两套向量**，并在展示时标注版本。

**需要 key：否（这是规范文档 + 计算公式，不是数据 feed）。**

### 1.9 Exploit-DB / Metasploit 的可枚举性

**Exploit-DB**

- 站点：<https://www.exploit-db.com/>
- searchsploit 说明：<https://www.exploit-db.com/searchsploit>
- 全量仓库（GitLab）：<https://gitlab.com/exploit-database/exploitdb>
  - 结构化清单：<https://gitlab.com/exploit-database/exploitdb/-/blob/main/files_exploits.csv>
- **无官方 REST/JSON API。** 可枚举方式：`git clone` 仓库后解析 `files_exploits.csv`，或用 `searchsploit -j`（JSON 输出）。
- 评级：**★★**（能稳定枚举，但要自建同步 + 解析；数据更新以仓库提交为准）。

**Metasploit**

- 仓库：<https://github.com/rapid7/metasploit-framework>（模块在 `modules/` 下：`exploits` / `auxiliary` / `post` …）
- 官方 RPC API 文档：<https://docs.rapid7.com/metasploit/rpc-api/>（`msfrpcd` / `msgrpc`，可用 JSON-RPC 程序化 `search` 模块）
- **无独立的「模块清单」静态 feed。** 可枚举方式：解析仓库 `modules/` 目录，或起 RPC 服务后查询。
- 评级：**★★**。
- 实务要点：KEV 的 CVE 与「是否有 Metasploit 模块 / 是否有公开 PoC」需要**你自己建映射表**，没有官方现成字段。

### 1.10 Certificate Transparency：crt.sh 与 CertStream

**crt.sh**

- 站点：<https://crt.sh/>
- **无官方文档化的 API/RSS。** 网页提供 `?q=&output=json` 形式的输出，但未作为正式 API 提供承诺。
- 实测：多次请求 `https://crt.sh/?q=example.com&output=json` 返回 `502`，另一次返回 `404` —— **稳定性差，不能作为生产依赖**。
- 评级：**★**（只能网页 / 不稳定 JSON）。

**CertStream**

- 站点：<https://certstream.calidog.io/>
- 端点为 WebSocket 流：`wss://certstream.calidog.io/`（出自官方客户端 README：<https://github.com/CaliDog/certstream-python>）
- 服务端源码：<https://github.com/CaliDog/certstream-server>（许可证：MIT）
- **需要 key：否。** 格式：JSON over WebSocket（每张新签发证书一条记录）。
- 知识背景：证书透明日志的权威清单在 <https://www.certificate-transparency.org/known-logs>；CertStream 本身是**第三方聚合，无 SLA**。
- 评级：**★★**。

---

## 2. 情报格式与交换标准

| 标准 | 定位 | 官方入口 | 最小上手成本 |
|---|---|---|---|
| **STIX 2.1** | CTI 对象模型 / 序列化格式（OASIS Standard） | <https://docs.oasis-open.org/cti/stix/v2.1/os/stix-v2.1-os.html>（2021-06-10；含 Errata 01 CSD01，2025-04-02：<https://docs.oasis-open.org/cti/stix/v2.1/stix-v2.1.html>） | 2–3 天：理解 SDO/SRO/SCO、`bundle`、`indicator`+`pattern`（STIX Patterning） |
| **TAXII 2.1** | 交换协议（HTTPS 之上的 REST API） | <https://docs.oasis-open.org/cti/taxii/v2.1/taxii-v2.1.html>（OASIS Standard，2021-06-10） | 1 天：`api_root` / `collections` / `objects` 三个层级 + `Accept: application/taxii+json;version=2.1` |
| **MISP 核心格式** | MISP 事件 JSON（事实标准，被大量工具互通） | 规范：<https://www.misp-standard.org/rfc/misp-standard-core.html>；标准列表：<https://www.misp-standard.org/standards/>；软件：<https://github.com/MISP/MISP> | 1 天读格式；1 周跑起实例并理解 Event/Attribute/Object/Tag/galaxy |
| **OpenCTI** | 开源 CTI 平台（图谱化存储 + 集成） | 部署文档：<https://docs.opencti.io/latest/deployment/overview/>；仓库：<https://github.com/OpenCTI-Platform/opencti>；产品页：<https://filigran.io/products/opencti> | 1–2 天能起 docker-compose；真正上手 2–4 周 |
| **Sigma 规则** | 厂商无关的检测规则（YAML → 各 SIEM 查询） | 文档：<https://sigmahq.io/docs/basics/rules.html>；规则库：<https://github.com/SigmaHQ/sigma>；转换器：<https://github.com/SigmaHQ/pySigma> | 半天写第一条；1 周懂 logsource/pipeline/field mapping |
| **YARA 规则** | 样本 / 文件特征匹配（恶意软件识别） | 文档：<https://yara.readthedocs.io/en/stable/>；规则语法：<https://yara.readthedocs.io/en/stable/writingrules.html>；仓库：<https://github.com/VirusTotal/yara>（最新 release **v4.5.8**，见 <https://github.com/VirusTotal/yara/releases>） | 半天写第一条；长期练的是「写得准且不误报」 |

选型建议（按你的目标形态）：

- **资讯聚合器 / API 产品** → 内部统一 schema 自定，**对外输出至少支持 STIX 2.1 bundle**（可直接喂给 MISP/OpenCTI 用户）。
- **检测/攻防教学** → Sigma（日志侧）+ YARA（文件侧）是最短路径；ATT&CK 作为教学骨架。
- **平台级产品** → 别自造格式；用 STIX 2.1 + TAXII 2.1 入库，MISP 作为互通触点。

---

## 3. 中文 / 国内源

| 源 | 入口 | 可编程性 | 说明 |
|---|---|---|---|
| **CNNVD**（国家信息安全漏洞库） | <https://www.cnnvd.org.cn/> ；数据下载 <https://www.cnnvd.org.cn/home/data> | ★ | 纯 SPA（实测返回前端 HTML，非 JSON API）；数据下载需注册/实名。**未发现公开 API/RSS** [观察] |
| **CNVD**（国家信息安全漏洞共享平台） | <https://www.cnvd.org.cn/> ；漏洞列表 <https://www.cnvd.org.cn/flaw/list.html> | ★ | 实测 `521`（反爬 / 访问受限）。只能人工查看或谨慎抓取 [观察] |
| **FreeBuf** | RSS：<https://www.freebuf.com/feed> | ★★ | 实测 `200 text/xml`，可订阅 |
| **安全客** | RSS：<https://api.anquanke.com/data/v1/rss> | ★★ | 实测 `200 application/xml` |
| **先知社区（阿里云）** | RSS：<https://xz.aliyun.com/feed> | ★★ | 实测 `200 application/rss+xml` |
| **Seebug（知道创宇）** | RSS：<https://www.seebug.org/rss.xml> | ★★ | 实测 `200 application/xml` |
| **微步在线 X 情报社区** | <https://x.threatbook.com/> ；商业 API <https://api.threatbook.cn/> | ★ / ★★★（API 需付费） | 社区页有 JS 反爬 challenge（实测返回 challenge 页）；API 走商业授权 + key |
| **奇安信威胁情报中心（ALPHA）** | <https://ti.qianxin.com/> | ★ | 平台需登录；情报查询属产品能力 |
| **腾讯安全威胁情报中心 TIX** | <https://tix.qq.com/> ；API 概览 <https://tix.qq.com/apinterface/overview> | ★★★（商业） | 有正式 API 文档，需 key / 商务授权 |
| **阿里云漏洞库 AVD** | <https://avd.aliyun.com/> | ★ | 网页列表，**未发现官方 API** [观察]；AVD 编号与 CVE/CWE 可对照 |

**结论**：中文侧的「可编程」基本只有 **RSS 这一档**（FreeBuf / 安全客 / 先知 / Seebug 四家可用）。**CNNVD / CNVD 没有公开 API，只能人工查看或谨慎抓取**，且要注意其访问条款与频率。情报级 API（微步 / 腾讯 TIX / 奇安信）都是商业授权。因此产品里的「中文资讯」应定位为**标题级资讯流**，不要当作结构化漏洞事实源——结构化事实一律回到 §1 的英文官方源。

---

## 4. 必须掌握的判断力

### 4.1 CVSS 的局限

- CVSS 衡量的是**严重度（severity）**，不是**被利用的可能性（likelihood）**；官方 FAQ 明确两者的区别：<https://www.first.org/cvss/v4.0/faq>
- CVSS 分数由「评分者」给出，存在主观性；且 NVD 已**不再对所有 CVE 例行提供自己的 severity score**（<https://www.nist.gov/itl/nvd>）。
- v3.1 / v4.0 混用会导致分数不可比（见 §1.8）。
- 常见错误：把 CVSS 9.8 一律排到最前 —— 一个 CVSS 9.8 但无 PoC、不在 KEV、EPSS 极低的漏洞，优先级通常低于一个 CVSS 7.5 但在 KEV 里的漏洞。

### 4.2 EPSS：概率，不是严重度

- EPSS 输出是**未来 30 天被利用的概率 + 百分位**（<https://www.first.org/epss/>），与 CVSS 正交，**应当联合使用而不是互相替代**。
- 使用要点：关注 **percentile**（相对排名）比单看概率更稳定；用 **30 天历史**判断趋势（API 支持按日期回看，官方说明见 <https://www.first.org/epss/data>）。
- 版本切换会在某天造成整体分数跳变（v4→v5 于 2026-06-15 切换，见 §1.3），做时间序列时要记住「跨越模型版本边界 = 方法论变化，不是漏洞本身变化」。

### 4.3 KEV 的意义

- KEV = **已被在野利用的确证清单**（<https://www.cisa.gov/known-exploited-vulnerabilities-catalog>）。
- 它的价值在于**消除「是否有利用」这一维度的不确定性**：只要进了 KEV，就不需要再争论「会不会被利用」。
- 但它**不衡量你的资产是否受影响**、也**不衡量影响面**——所以 KEV 必须与「资产清单 / 受影响产品」结合，才能变成可执行工单。

### 4.4 误报与信噪比

- 漏洞数据天然噪声大：同一漏洞会以 CVE / GHSA / OSV / 厂商公告 / CNNVD 编号多份出现 → **必须先按 CVE 对齐再聚合**，否则日报全是重复。
- 误报来源：CVE 重复编号、`Rejected` 状态记录、无 CVE 的资讯稿、被撤回的 advisory（OSV 提供「含 withdrawn 记录」的全量 dump，注意过滤）。
- 实践原则：**用 KEV 作为「确定性锚点」**，把 EPSS / CVSS 只作为排序微调；不要把纯资讯标题直接当漏洞处理。

### 4.5 漏洞优先级：CISA 的 SSVC 决策模型

- CISA 官方页：<https://www.cisa.gov/resources-tools/resources/stakeholder-specific-vulnerability-categorization-ssvc>
- 官方 SSVC Guide（PDF，实测可下载）：<https://www.cisa.gov/sites/default/files/publications/cisa-ssvc-guide%20508c.pdf>
- 在线计算器：<https://www.cisa.gov/ssvc-calculator>
- 框架源头（CERT/CC）：<https://certcc.github.io/SSVC/>；参考实现仓库：<https://github.com/CERTCC/SSVC>

SSVC 由 CMU SEI 与 CISA 于 2019 年提出，CISA 于 2020 年定制了自己的决策树。它在以下五个输入上做决策：

1. Exploitation status（利用状态）
2. Technical impact（技术影响）
3. Automatable（是否可自动化利用）
4. Mission prevalence（任务/业务覆盖面）
5. Public well-being impact（公共福祉影响）

输出四类决策：**Track / Track\* / Attend / Act**（<https://www.cisa.gov/resources-tools/resources/stakeholder-specific-vulnerability-categorization-ssvc>）。

> 对聚合器的启示：排序**不应是单一分数**，而应是「决策类别」。一个可落地的近似：
> `Act = 在 KEV` 或 `EPSS ≥ 高阈值 且 资产命中`；`Attend = EPSS 高但资产未确认`；`Track = 其余`。

---

## 5. 最小可行聚合器（MVP）架构

```
 拉取 (fetch) → 归一化 (normalize) → 去重 (dedupe) → 打分排序 (score) → 渲染 (render) → 分发 (deliver)
```

### 5.1 各阶段要点

1. **拉取**：KEV JSON（每日 1 次）、EPSS CSV（每日 1 次全量）、NVD API（增量，按 `lastModStartDate/lastModEndDate`，**必须遵守 5/50 per 30s 限速并带 key**）、OSV/GHSA（按需 querybatch / REST）、ATT&CK STIX（跟版本）、RSS（每 15–60 min）。
   - 工程要求：条件请求（ETag / If-Modified-Since）、失败重试与退避、每源单独记录「上次成功时间」。
2. **归一化**：映射到统一 schema（见 §5.2）。关键：**保留原始来源与原始 ID**，不要归一化时丢信息。
3. **去重**：主键优先级 `CVE` > `GHSA/OSV id` > `(source, source_id)`；跨源用别名表（OSV 的 `aliases`、GHSA 的 `cve_id`）把多条记录折叠到同一个 CVE。
4. **打分排序**：先算决策类别（SSVC 简化版），再在类内用 `EPSS percentile` + 时间新鲜度排序。**分数要可解释**（输出 breakdown）。
5. **渲染**：同一份内部 JSON → Markdown（日报/周报）、结构化 JSON（API）、RSS（订阅）。
6. **分发**：邮件（RSS→email 或模板）、IM webhook（Slack / 飞书 / 企业微信）、只读 API（`/v1/items?since=`）。

### 5.2 数据模型字段建议

```jsonc
{
  "id": "cve-2025-21418",                 // 内部稳定 ID
  "kind": "vulnerability",                // vulnerability | news | indicator
  "cve_ids": ["CVE-2025-21418"],          // 0..n
  "aliases": ["GHSA-xxxx", "OSV-xxxx"],   // 跨源折叠用
  "sources": [                            // 保留全部一手来源
    { "source": "nvd",  "source_id": "CVE-2025-21418", "url": "..." },
    { "source": "kev",  "source_id": "CVE-2025-21418", "url": "..." }
  ],

  "title": "...",
  "summary": "...",                        // 归一化后的短描述
  "locale": "en",                          // 便于中文源混排
  "published_at": "2025-01-14T00:00:00Z",
  "modified_at":  "2026-10-08T00:00:00Z",
  "fetched_at":   "2026-10-13T02:00:00Z",

  "kev": { "in_catalog": true, "date_added": "2025-01-14",
           "due_date": "2025-02-04", "ransomware_use": "Known" },

  "epss": { "score": 0.42, "percentile": 0.96, "date": "2026-10-12",
            "model_version": "v2026.06.15" },

  "cvss": [
    { "version": "3.1", "vector": "CVSS:3.1/AV:N/...", "base_score": 9.8, "severity": "CRITICAL" },
    { "version": "4.0", "vector": "CVSS:4.0/AV:N/...", "base_score": 9.3, "severity": "CRITICAL" }
  ],

  "cwe_ids": ["CWE-78"],
  "affected": [ { "vendor": "...", "product": "...", "ecosystem": "PyPI", "package": "...", "versions": "<4.2.1" } ],

  "exploits": { "exploit_db": ["EDB-51234"], "metasploit": ["exploit/linux/..."], "public_poc": true },

  "references": [ { "type": "advisory", "url": "..." } ],
  "tags": ["rce", "kev", "network"],

  "status": "active",                      // active | rejected | withdrawn
  "raw_hash": "sha256:...",                // 原始载荷哈希，判重/审计
  "dedupe_key": "CVE-2025-21418",

  "score": { "decision": "act",            // act | attend | track | track_star
             "value": 98.2,
             "breakdown": { "kev": 40, "epss_percentile": 35, "cvss": 13.2, "recency": 5, "exploit_available": 5 } }
}
```

设计原则：`sources` / `cvss` / `affected` 用数组（一个漏洞常有多个来源、多版本评分、多个受影响包）；`score.breakdown` 必填（可解释性）；`raw_hash` + `fetched_at` 用于增量同步与审计。

---

## 6. 学习清单（按依赖顺序）

**阶段 A｜1 小时能懂（先建立词汇表）**

1. CVE 是什么、编号与 `Rejected` 状态的含义。
2. CVSS 是什么、Base/Temporal/Environmental 的区别（<https://www.first.org/cvss/v4.0/user-guide>）。
3. CISA KEV 是什么、为什么它是最强信号（<https://www.cisa.gov/known-exploited-vulnerabilities-catalog>）。
4. EPSS 是什么、为什么和 CVSS 正交（<https://www.first.org/epss/>）。
5. RSS / JSON 解析、HTTP 条件请求（ETag / If-Modified-Since）、退避重试。
6. 三个数字的区别：severity（CVSS）、probability（EPSS）、confirmed exploitation（KEV）。

**阶段 B｜几天到一周（能跑通管线）**

7. NVD API 2.0 的分页、增量查询与限速（<https://nvd.nist.gov/developers/start-here>）。
8. OSV / GHSA 的查询与别名折叠（<https://google.github.io/osv.dev/api/>）。
9. STIX 2.1 对象模型与 TAXII 2.1 三层结构（§2）。
10. MITRE ATT&CK 的结构（Tactic / Technique / Group / Software）与 STIX 数据读取（§1.6）。
11. CWE 的层级（Class / Base / Variant）与 CWE↔CVE 映射（§1.7）。

**阶段 C｜长期（决定产品深度）**

12. **SSVC 与其调参**：把「利用状态 + 影响 + 覆盖面」变成决策类别，而不是单一分数（§4.5）。
13. **Sigma 规则编写与转换**（logsource / pipeline / SIEM backend 映射）：<https://sigmahq.io/docs/basics/rules.html>。
14. **YARA 规则编写**（要练到低误报）：<https://yara.readthedocs.io/en/stable/writingrules.html>。
15. **CT 日志**：证书透明机制、certstream 流式处理、日志清单 <https://www.certificate-transparency.org/known-logs>。
16. **MISP / OpenCTI 运维与互通**：自己做情报的生产者而非消费者（§2）。
17. **威胁建模 + 情报生产**：从原始事件到可行动情报（评估来源可信度、情报分级）。
18. **工程侧长期能力**：增量同步与幂等、多源去重算法、打分可解释性、分发渠道的限流与去重。

---

## 7. 一句话落地建议

先用 **KEV + EPSS CSV + OSV**（**三个都无需 key、都免费**）跑通「拉取 → 归一化 → 去重 → 打分 → Markdown 日报」的最小闭环；再补 NVD API key 与 GHSA token 提升覆盖；ATT&CK / STIX / MISP 作为「对外输出与平台互通」的第二步；中文源只做**标题级资讯**，绝不作为结构化事实源。
