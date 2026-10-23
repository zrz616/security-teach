# 06 · CDN 安全市场调研：产品形态、定价与可复制性

> 目的：为「从 CDN 客户出发做安全服务，并拓展安全资讯 / 资产测绘 / 漏洞评估」立项提供**别人已经怎么做、以什么形态卖、卖多少钱**的事实底稿。
>
> 撰写约束（本文件严格遵守）：
> - 产品形态与价格的断言**必须**给厂商官方页 / 官方定价页链接；
> - 中国区定价页常有登录墙或动态渲染 / 反爬，**读到什么写什么**，读不到一律标 `[未核实]`，**不用二手报价或猜测填坑**；
> - 明确区分「✅ 已核实（官方页原文）」「🔶 推断（基于已核实事实的推理，非官方表述）」「⛔ 未核实 / 未公开」。

**图例**：✅ = 官方页原文可直接核实；🔶 = 基于事实的推断；⛔ = 官方公开渠道未找到 / 抓取受限。

---

## 0. 方法与可信度说明

- 抓取时间：2026-10-13。价格随时会变，落地选型前需复核。
- 中国大陆厂商（腾讯云、阿里云、网宿、白山云、知道创宇、FOFA 等）的定价页常用 JS 挑战、登录墙或按 UA 拦截；本文件对每个「读到 / 读不到」都做了标注。
- 若官方页直连被拦（如 HTTP 403/406/521），本文件使用 **同一官方 URL 的阅读器渲染快照**（`r.jina.ai` 前置）取正文，并在行内注明；这仍是官方页面内容，**不是第三方报价**。
- 本文件**只**产出这一个文件，未改动仓库其他内容。

---

## 1. CDN 厂商做安全的三条典型路径

### 1.1 Cloudflare：把安全「内嵌进 CDN 套餐」的教科书样本 ✅

Cloudflare 是最像「CDN 变安全公司」的样本：**CDN、DDoS、WAF、Bot、Zero Trust 全部按「套餐层级 + 加购（add-on）」售卖，且小套餐就把基础安全包含进去**。

**域名 / CDN 套餐（含安全能力）** — 官方页：<https://www.cloudflare.com/plans/network-cdn> ✅

| 套餐 | 价格 | 主要安全能力（原文） |
|---|---|---|
| Free | $0 / 月 | Unmetered DDoS Protection、CDN、Universal SSL、**Web Application Firewall (WAF) 均含**；Bot Mitigation = Simple bots |
| Pro | $20/月（按年付）或 $25/月（按月付） | 在上面基础上 Bot Mitigation = Easy-to-detect bots；Lossless Image Optimization |
| Business | $200/月（按年付）或 $250/月（按月付） | Bot Mitigation = Sophisticated bots + basic bot analytics；100% Uptime SLA、PCI DSS 4.0 |
| Contract / Enterprise | 定制，按年 | Bot Mitigation = All bots、anomaly detection、custom CAPTCHAs、advanced bot analytics；API Shield、L3 Network DDoS（Magic Transit）、China Network Access 等均为 Custom |

- 关键事实：**WAF 与「不限量 DDoS 防护」在 Free 套餐就已包含**；安全能力随套餐「阶梯解锁」（Bot 从「简单机器人」到「全部机器人 + 异常检测」）。
- 高级安全是**加购 / 合约项**：API Shield、Magic Transit（L3 DDoS）、China Network Access、AI Security for Apps 均标注 `Custom`。
- 加购项也有公开价：Client-Side Security `$0.099/1k requests`、Log Explorer `$1/GB`、Advanced Certificate Manager `$10/月`、Argo Smart Routing / Load Balancing 自 `$5/月`（同页）。

**SASE / Zero Trust（安全独立成线，但仍分层 + 席位计费）** — 官方页：<https://www.cloudflare.com/plans/sase-zero-trust> ✅

| 套餐 | 价格 | 说明 |
|---|---|---|
| Free | $0 | ≤50 用户；ZTNA、SWG、DEX、网络流量监控均含 |
| Pay-as-you-go | **$7 / 用户 / 月** | 无用户数上限；CASB（只读集成）、DLP（受限） |
| Contract | 定制（按用户年价） | 全功能 CASB、DLP、RBI、Email Security、Network Services 等为 add-on |

- 计算 / 存储等开发者产品的独立价目见 <https://www.cloudflare.com/plans/>（Workers、R2、AI 等纯用量计费）。
- Enterprise 入口：<https://www.cloudflare.com/plans/enterprise/>。

> **形态结论（Cloudflare）**：安全 = **「套餐分层内嵌 + 高级项加购 + 企业合约」**三件套；安全不是单独跑一张价格表，而是 CDN 套餐的**功能阶梯**。这是「CDN 厂商做安全」最省客户认知成本的路径。

### 1.2 Akamai：从 CDN 长出**独立安全产品线**，价格一律「联系销售」 ✅/⛔

Akamai 的路径与 Cloudflare 相反：安全已经**独立成完整产品线**，且**不公开价格**。

- 官方安全产品总览：<https://www.akamai.com/products/security> ✅（直连 403，以下据同 URL 阅读器渲染快照）
  - **App & API Security**：API Security、App & API Protector、Firewall for AI、Client-Side Protection & Compliance
  - **Bot & Agent Control**：Account Protector、Content Protector、Bot Manager、AI Brand Presence
  - **Segmentation**：Akamai Guardicore Segmentation
  - **Zero Trust**：Workforce Protector（原 LayerX）、Secure Internet Access、Enterprise Application Access、Akamai MFA、ICAM
  - **Infrastructure Security**：Edge DNS、**Prolexic**（DDoS 清洗）、IP Accelerator、DNS Posture Management、Brand Guardian
- **定价**：Akamai 官网 Pricing 导航中，「Security and Delivery」只有 `Contact Sales` 与 `Free trials` **两项**，**没有任何安全产品公开标价**：<https://www.akamai.com/why-akamai/contact-us/contact-sales>。
  - 唯一公开定价的是 **Akamai Cloud（Linode 系云计算）**：<https://www.akamai.com/cloud/pricing>（GPU / CPU / Kubernetes / Object Storage 等）。
  - 单产品页形态：<https://www.akamai.com/products/app-and-api-protector>（直连 403）。

> **形态结论（Akamai）**：安全作为**独立产品线**按企业合约销售，**价格完全非公开**（⛔ Akamai 安全产品官方定价 = `[未核实]`：官网仅提供 Contact Sales，无公开价目）。

### 1.3 国内四家：安全是「增值模块」还是「独立产品线」

#### (a) 网宿科技 —— CDN 与「云安全」并列为两条产品线，安全可单独成 SKU ✅/⛔

- 官网首页：<https://www.wangsu.com/>（直连 406，据同 URL 阅读器渲染快照）
  - 产品菜单一级分类含 **「安全」**（与「CDN 与网络」「边缘智算与 AI」平级）。
  - 安全产品线包含：**DDoS 云清洗、Web 应用防火墙（WAF）、SASE 一体化办公安全、云安全管理平台、数据库审计、日志审计、安全风险感知**等，即**独立安全产品**，而非仅 CDN 的一个勾选项。
  - 同时提供**打包方案**：<https://www.wangsu.com/solution/3>（安全加速解决方案）、<https://www.wangsu.com/solution/360>（出海安全加速，官方描述「融合全球 CDN 加速、DDoS 防护、云安全及边缘 AI 能力」）。
- 单产品官方页（直连 406，据同 URL 渲染快照）：
  - DDoS 云清洗：<https://www.wangsu.com/product/51> ✅ —— 原文卖点含「全球 3000+ 安全防护节点、100+ 清洗中心，全网防护容量超 20Tbps」「零部署、零改造、零运维」「全业务支持 **按需付费**」。
  - WAF：<https://www.wangsu.com/product/52>。
- 在线商城：<https://online.wangsu.com/> —— 首页 banner 原文提及「在线下单 首购 6 折，云分发及安全类多款产品免费试用」。
- 英文站（安全定位）：<https://en.wangsu.com/>，官方 tagline 为「Expert in Security and Acceleration CDN Edge Computing Cloud Security SD-WAN」。
- ⛔ **具体价格未公开**：官网无安全产品价目表，成交价走商务。

> **形态结论（网宿）**：安全是**独立产品线**（可单卖），也做「加速 + 安全」打包方案；计费「按需付费」但**无公开价 = `[未核实]`**。

#### (b) 白山云 —— 安全是独立产品大类 + 独立子品牌 ✅/⛔

- 官网：<https://www.baishan.com/> ✅（首页「产品服务」含独立 **「安全」** 分类，与「网络与 CDN」「智算」并列）。
  - 业务安全：云 WAF（`/product-des/14.html`）、DDoS 防护（`/product-des/12.html`）、SDK 安全加速（`/product-des/15.html`）、SCDN（`/product-des/13.html`）
  - 办公与企业安全：SASE（`/product-des/9.html`）、极速可信访问 VTN（`/product-des/11.html`，**「探索版」永久免费**）、安全智能组网（`/product-des/10.html`）
  - 安全服务：渗透测试（`/product-des/7.html`）、安全重保（`/product-des/6.html`）、应急响应（`/product-des/8.html`）
  - 独立子品牌「**云盾**」(<https://www.yundun.com>)、海外品牌 EdgeNext(<https://www.edgenext.com/>)。
- 官网自述基础设施：1500+ 全球边缘节点、90 Tbps+ 带宽储备、**7600 亿次+/日请求**（用于第 5 节数据面推断）。
- ⛔ **未公开价格**。

> **形态结论（白山云）**：安全 = **独立产品线 + 子品牌 + 免费引流产品（VTN 探索版永久免费）**；价格不公开 = `[未核实]`。

#### (c) 腾讯云 EdgeOne —— 安全**内嵌进 CDN 套餐**，高级能力加购 ✅

- 中国区官方计费文档 ✅：
  - 套餐费用：<https://cloud.tencent.com/document/product/1552/94158>（据同 URL 渲染快照）
    - 个人版 **¥29.9/套/月**（含 50 GB 流量 + 300 万次请求）
    - 基础版 **¥399/套/月**（500 GB + 2000 万次）
    - 标准版 **¥3,800/套/月**（3 TB + 5000 万次）
    - 企业版 **定制报价**
  - 计费概述：<https://cloud.tencent.com/document/product/1552/94156> —— 计费 = **基础服务资费（套餐费用 + 套餐外超量）+ 增值服务资费**；增值项含**智能加速、Bot 管理、Web 防护自定义规则、速率限制规则**（以 VAU 用量单元计费，`0.1 元/个 VAU`）。
  - 官方定价示例 3 明确：**标准版套餐「内含 20 个自定义规则精准匹配策略 + 5 个速率限制规则」，Bot 请求按 `0.1 元/个 VAU` 计费（5000 万次 Bot 请求 ≈ 500 元/月）**；OWASP Top 10 托管规则 `0 元`（含在套餐内）。
  - 独立 DDoS 防护费用单列：<https://cloud.tencent.com/document/product/1552/94162>。
- 国际站价格（美元，可交叉验证分层逻辑）：<https://edgeone.ai/pricing> ✅
  - Free `$0`（Unmetered Security Traffic / Security Requests / SSL；含 Platform DDoS Protection、WAF Ruleset、Basic CC Attack Protection）
  - Personal `$1.4/月`（原价 $4.2）、Basic `$57/月`、Standard `$590/月`、Enterprise 定制
  - 表格显示 **Bot Management 在 Personal/Basic 为「Paid Value-Added」，到 Standard 起随套餐提供**。

> **形态结论（EdgeOne）**：**安全绑定 CDN 套餐**（基础 WAF / CC / 平台级 DDoS 免费含；Bot / 精细规则 / 独立 DDoS 加购或按 VAU 用量计），价格高度公开。是「国内可对标 Cloudflare」的样本。

#### (d) 阿里云 —— CDN 与安全（WAF / DDoS）是**两套独立产品、独立计费** ✅

- CDN 计费（官方文档）：<https://help.aliyun.com/zh/cdn/product-overview/billing-overview> ✅
  - 「CDN 计费 = **基础服务计费（必选）+ 增值服务计费（可选，单独计费）**」。
  - **增值服务** = 静态 HTTPS 请求、静态 QUIC 请求、实时日志投递 —— **不含 WAF/DDoS 主体**。
- CDN 价格详情：<https://www.aliyun.com/price/detail/cdn> ✅
  - 按流量（中国内地）：0–10TB **¥0.24/GB**，>1PB **¥0.15/GB**；静态 HTTPS 请求 **¥0.05/万次**。
  - 该页含 **「CDN WAF 计费」** 独立小节：按账户维度对开启 WAF 的域名汇总请求数阶梯计费（1–20000 请求 ¥0.1 固定；20001–500000 请求 **¥0.2/万次**……），并注明 **「CDN WAF 即将下线，请使用边缘安全加速 ESA」** —— 即阿里云正把「CDN 内嵌 WAF」迁移为独立边缘安全产品 **ESA**。
- WAF（独立产品，价格公开）：<https://help.aliyun.com/zh/waf/web-application-firewall-3-0/editions> ✅ 与 <https://help.aliyun.com/en/waf/web-application-firewall-3-0/billing-description> ✅
  - 版本：基础版 / 高级版 / 企业版 / 旗舰版 / 按量付费版。
  - **包年包月单价**：基础版 **¥980/月**、高级版 **¥3,880/月**、企业版 **¥9,800/月**、旗舰版 **¥29,800/月**。
  - 加购：Bot 管理 Web 保护 ¥8,000/月、App 保护 ¥12,000/月；API 安全（高级版）¥5,000/月；额外 QPS 中国内地阶梯 ¥3→¥1.8/QPS/月；日志服务 ¥500/TB/月。
- DDoS（独立产品，价格公开）：<https://www.aliyun.com/price/detail/ddos> ✅
  - DDoS 高防（中国内地，新 BGP）：保底防护 **30 Gbps ≈ ¥2.08 万/月**、60 Gbps ≈ ¥4.68 万/月、100 Gbps ≈ ¥32.8 万/年；按天弹性后付费（0–5 Gbps ¥800/天 起）。
  - DDoS 原生防护企业版：100 Mbps **¥46,800/月** 起。

> **形态结论（阿里云）**：**安全 = 独立产品线、独立计费、价格公开**；CDN 与安全只在控制台/接入层（CNAME、ESA）打通，**账单上是两套产品**。

#### 三条路径对比：安全是「绑定套餐」还是「单独计费」

| 厂商 | 形态 | 绑定 CDN 套餐 还是 单独计费 | 公开价格 | 依据 |
|---|---|---|---|---|
| Cloudflare | CDN 套餐内嵌安全 + 高级加购 + Zero Trust 席位 | **两者都有**：WAF/DDoS 含在套餐（含 Free）；高级项加购 / 合约 | ✅ 公开 | [network-cdn](https://www.cloudflare.com/plans/network-cdn)、[sase](https://www.cloudflare.com/plans/sase-zero-trust) |
| Akamai | 独立安全产品线 | **单独销售**（企业合约） | ⛔ 无公开价（仅 Contact Sales） | [products/security](https://www.akamai.com/products/security) |
| 腾讯云 EdgeOne | 安全内嵌套餐 + 增值加购 | **绑定套餐为主**，高级项按 VAU 加购；独立 DDoS 单列 | ✅ 公开 | [94158](https://cloud.tencent.com/document/product/1552/94158)、[94156](https://cloud.tencent.com/document/product/1552/94156) |
| 阿里云 | CDN 与安全两套独立产品 | **单独计费**（CDN 增值服务不含安全；WAF/DDoS 独立） | ✅ 公开 | [cdn billing](https://help.aliyun.com/zh/cdn/product-overview/billing-overview)、[cdn price](https://www.aliyun.com/price/detail/cdn) |
| 网宿科技 | CDN 与「云安全」并列产品线 + 打包方案 | **可单独成 SKU**（也做打包方案） | ⛔ 无公开价 | [wangsu.com](https://www.wangsu.com/)、[product/51](https://www.wangsu.com/product/51) |
| 白山云 | 安全独立产品大类 + 子品牌 | **可单独售卖** | ⛔ 无公开价 | [baishan.com](https://www.baishan.com/) |

---

## 2. 安全资讯 / 情报类业务：流量从哪来、靠什么变现

### 2.1 FreeBuf（斗象科技旗下）—— 「媒体 → 会员/知识付费 → 企业服务」三层漏斗 ✅/⛔

- 官方门户：<https://www.freebuf.com/>（直连 405 反爬；会员中心入口 <https://m.freebuf.com/member> 亦返回 405）。
- 官方身份：FreeBuf 是**网络安全行业门户/新媒体**，同属**斗象科技**，与「漏洞盒子」（<https://www.vulbox.com/>，网络安全众测平台）、斗象智能安全产品体系并列（斗象官网 <https://www.tophant.com/>）。
- 变现结构（🔶 基于官方站点结构 + 机构公开资料）：
  1. **广告 / 厂商投放 / 会议活动**（门户流量变现）；
  2. **会员与知识付费**（「FreeBuf 会员中心」、**FreeBuf 知识大陆**付费社群/课程）；
  3. **企业服务转化**：把流量沉淀为**漏洞盒子众测平台**与**斗象智能安全**的企业客户（风险感知、SRC 建设与运营、众测）；
  4. **招聘/活动**等垂直服务。
- ⛔ **FreeBuf 会员具体价格 `[未核实]`**：会员页直连被 405 拦截，未读到公开价目。

> **漏斗设计**：免费资讯/漏洞分析聚流量 → 会员/知识大陆做小额付费转化 → 企业级众测与安全运营平台做高客单承接。**媒体是获客入口，不是利润中心**。🔶

### 2.2 安全客（360 安全 KER）—— 媒体 + 招聘 + 活动 + 商务合作 ✅

- 官方站：<https://www.anquanke.com/> ✅（标题「安全 KER - 安全资讯平台」，隶属 360 体系）。
- 变现结构（官方导航直接可见）：**安全资讯 / 安全知识 / 安全工具**内容 → **招聘（职位列表，企业付费发布）** → **活动（安全大会、SRC 冲榜、沙龙）** → **商务合作**。
- 与 FreeBuf 类似，本质是**「内容媒体 + 行业服务」**模式；未见面向个人的付费会员价目。

### 2.3 微步在线 ThreatBook —— 「免费情报社区 → 付费会员 → 企业情报产品」的完整漏斗 ✅

- 企业站（产品线）：<https://www.threatbook.cn/> ✅ —— 产品含 **威胁情报平台 NGTIP（本地化）、威胁情报 SaaS API、TDP（流量检测）、OneSEC（EDR）、OneDNS（安全 DNS 网关）、OneSIG（边界防护）、OneCare（安全服务）、OneSOC（AI 原生 SOC）**；工具社区含 **X 情报社区、HFish 蜜罐、S（云沙箱）、SHELLPUB**。
- 免费社区「X 情报社区」：<https://x.threatbook.com/> ✅ —— 免费查询威胁情报/漏洞情报/资产测绘/Graph。
- **社区会员定价（官方页）**：<https://x.threatbook.com/v5/pricing> ✅（直连 JS 渲染，据同 URL 渲染快照）
  - **免费版**：基础情报查询、平台注册用户免费（约 10 次/天 检索、100 条/月 等）。
  - **基础版**：**¥468 / 6 个月起**（面向个人安全从业者，日常告警排查）。
  - **高级版**：**¥798 / 2 个月起**（面向安全分析师进阶，提升研判/分析/调查效率）。
  - **定制版**：面向企业安全运营，**「详询报价」**（企业级，含 API 集成、企业管理、专属 CSM）。
  - 权益维度含：查询次数/天、批量查询、沙箱、Graph 深度、API（IP 信誉/失陷检测/域名分析/XGPT）、空间资产测绘、企业管理（IP 资产认领、API 监控/统计报告、成员管理）。

> **漏斗设计（微步）**：**免费社区聚安全从业者 → 个人付费会员（¥468 起）做习惯培养 → 企业版 NGTIP/API/TDP 做高客单**；社区本身是企业情报产品的**人才池与信任前置**。✅

### 2.4 知道创宇 —— 「免费云防护/免费测绘 → 付费安全服务」✅

- 免费云安全平台：<https://www.yunaq.com/> ✅ —— 官方定位「国内专业的**免费**云网站保护平台」，提供**免费云 WAF、高危 CDN 加速、DDoS 防护**；官方明示「**中小用户可使用免费版获得基础云 WAF、高防 CDN 服务**」。
- 付费安全产品矩阵：<https://defense.yunaq.com/> ✅ —— **创宇盾**（政企网站防护 / 合规）、**抗D保**（大流量清洗）、**加速乐 SCDN**（安全内容分发，1000+ 节点）、**云防御态势感知指挥平台**、**业务安全舆情监测服务**等。
- 资产测绘侧：**ZoomEye**（见第 3 节）与 **ZoomEye Pro / ZoomEye 互联网攻击面管理平台**（<https://easm.zoomeye.org/>）。
- 企业主体与定位：<https://www.knownsec.com/>、<https://www.yunaq.com/overview> ✅（2016 年 1800+ 团队、定位「网络空间测绘 + 云防御 SaaS」）。
- ⛔ 创宇盾/抗D保**具体价格未公开**。

> **转化路径**：免费云 WAF/CDN 覆盖海量中小网站 → 付费升级接**创宇盾/抗D保/加速乐** → 政企客户再叠加 **ZoomEye Pro / 攻击面平台 / 重保** 等企业服务。**「免费防护工具」是知道创宇最大的获客飞轮**。✅

### 2.5 奇安信（补充参考）—— 全产品线企业安全，无公开价格 ✅/⛔

- 官方产品总览：<https://www.qianxin.com/product/index> ✅ 与 <https://www.qianxin.com/service/detail/pid/37>（渗透测试服务）等。
- 定位为**企业级全网安全产品线**（大数据安全分析、网关、终端、网站安全、云安全、数据安全……），以项目制 / 合约制销售。
- ⛔ **无公开价目**：产品页均为「立即咨询 / 提交需求」。

---

## 3. 资产测绘 / 攻击面管理（ASM）国内玩家：形态与计费

### 3.1 FOFA（华顺信安）—— 会员订阅 + F 点「额度包」，漏斗清晰 ✅

- 官方定价页：<https://fofa.info/vip> ✅（英文站 <https://en.fofa.info/vip>）
  - **注册用户**：免费（非商业用途）——页面查询 300 次/月、数据量 3,000 条/月、44 个语法、1 用户。
  - **个人版**：页面显示 `¥199` 与 `¥119/月` 两档（页面有「月 / 年」切换；**两档对应月付与年付折算，具体映射为推断** 🔶）——10,000 次查询/月、100,000 条数据/月、60 语法、1 用户。
  - **专业版**：`¥999` / `¥719/月` —— 80,000 次查询/月、800,000 条/月、统计聚合 API。
  - **商业版**：`¥9,999` / `¥7,199/月` —— 900,000 次查询/月、9,000,000 条/月、**5 用户**、历史分析、**可商用**。
  - **企业版 V2**：**¥36,000/月起** —— 查询/数据量可定制（页面 500 万次/月、5,000 万条/月）、用户数可定制、**企业资产管理监控、攻击面梳理、数据刷新、资产线索拓线**。
  - **F 点（虚拟货币/额度包）**：10,000 F点 **¥35**；100,000 F点 **¥350**；400,000 F点 **¥1,200**（用于免费额度用尽后继续查询/导出）。
- **形态**：查询平台（网页）+ **API**（查询/聚合接口，按会员档位限制并发与可导出字段）+ 企业版（资产管理监控/攻击面梳理）。

> **漏斗设计（FOFA）**：免费查询拉注册 → 个人/专业/商业会员（¥199–¥9,999）→ **企业版 V2（¥36,000/月起）做企业级攻击面与资产管理**；**F 点**把「超额用量」变成可零售的额度包。✅

### 3.2 ZoomEye（知道创宇）—— 免费查询 → 会员订阅 → EASM/DarkEye 企业版 ✅

- 官方定价页：<https://www.zoomeye.ai/pricing>（直连 403；据**同 URL 阅读器渲染快照**读取）✅
  - **Free**：月最大结果 3,000、5 页、API 速率 0.5 req/s、ZoomEyeGPT 5 次/天。
  - **Personal**：原价 ~~$708~~ → **$190 / 年**（约省 73%）——100,000 结果/月、50 页、71 个可导出字段。
  - **Professional**：~~$1,908~~ → **$1,090 / 年** —— 800,000 结果/月、100 页、74 字段。
  - **Business**：~~$19,188~~ → **$10,990 / 年** —— 10,000,000 结果/月、API 2 req/s、78 字段、24/7 技术支持。
  - **Corporate**：~~$191,988~~ → **$100,000 / 年** —— 50,000,000 结果/月、API 5 req/s，**含 DarkEye（暗网监控、凭证泄露监控、客户数据泄露监控、VIP 保护）** 与 **EASM（50 域名的资产发现、证书管理、网页发现、漏洞扫描与复核）**。
  - **Enterprise**：定制。
  - 计费说明原文：**ZoomEye Points = 1 Result**（点数即结果数）。
- **企业级 ASM 平台**：<https://easm.zoomeye.org/> ✅ —— 「ZoomEye 互联网攻击面管理平台」，提供资产发现、风险监测与治理（与会员版分开的企业产品）。
- 另有海外终身会员活动落地页 <https://www.zoomeye.org/>（页面标题为 Black Friday Lifetime Deal 活动）🔶。

> **漏斗设计（ZoomEye）**：免费查询 → 低门槛年度会员（$190 起）→ Business/Corporate 年费（$10,990–$100,000）叠加 **DarkEye + EASM** 企业模块 → 定制企业版。**会员是「个人/团队」，EASM/DarkEye 才是「企业攻击面产品」**。✅

### 3.3 360 Quake（网络空间测绘）—— 平台与产品明确，价格非公开 ✅/⛔

- 官方平台：<https://quake.360.net/>；产品页：<https://360.net/mobile/product-center/360-internet-space-and-asset-manage/surveying-system>；英文产品页：<https://360.net/en/product-center/security-intelligence/quake-cs-mapping-system> ✅
- 形态：**主动探测 + 可视化 + 查询的分布式测绘系统**（会员/查询平台），背后是 360 安全大脑数据；企业侧纳入 360 数字安全集团产品体系。
- ⛔ **价格 `[未核实]`**：Quake 会员/企业版**无公开定价页**（`quake.360.net` 会员入口需登录，未找到公开价目）。

### 3.4 华云安 —— ASM / VM / CSPM / CART 平台化，无公开价格 ✅/⛔

- 官网：<https://www.huaun.com/> ✅ —— 定位「以攻击者视角构建从检测→分析→响应的**攻击面管理**完整闭环」，产品覆盖 **ASM（攻击面管理）、VM（漏洞全生命周期管理）、CSPM（云安全态势管理）、CART（自动化攻击测试）、影子资产发现、勒索软件治理**；同时有 **SecOps** 与 **情报社区** 入口。
- ⛔ **价格 `[未核实]`**：官网产品/解决方案页无公开报价，走商务。

### 3.5 长亭科技 —— 产品矩阵齐全（含免费社区版引流），价格非公开 ✅/⛔

- 官网：<https://www.chaitin.cn/> ✅ 产品清单（官方页原文）：
  - **雷池 SafeLine**（下一代 WAF，<https://www.chaitin.cn/safeline>）
  - **洞鉴 X-Ray**（风险评估系统，<https://www.chaitin.cn/xray>）
  - **云图 Cloud Atlas**（**资产暴露面运营管理 / EASM**，<https://www.chaitin.cn/cloudatlas>）
  - **鉴微 Insight**（**风险运营管理平台 / 漏洞管理**，<https://www.chaitin.cn/insight>）
  - 万象 COSMOS（安全分析运营）、全悉 T-ANSWER、御衡 Alioth（BAS）、牧云 CloudWalker、**无锋（自动化渗透测试平台）**、MSS 安全托管服务 等。
- 免费引流：**Xray 社区版**（<https://xray.cool>）、CT Stack 安全社区（<https://stack.chaitin.com>）、百川云（<https://rivers.chaitin.cn>）—— 社区版扫描器免费 → 企业版平台付费。🔶（🔶 = 「免费社区版做引流」为基于官方站结构的推断，官方未直接表述该漏斗）
- ⛔ **价格 `[未核实]`**：官网无公开价目。

### 3.6 微步（资产测绘维度）

- X 情报社区含 **资产测绘**（搜索语法 `app="泛微-E-cology"` 等）与企业版权益（IP 资产认领、API 监控报告），定价见 2.3 节。✅ <https://x.threatbook.com/v5/pricing>

### 3.7 火山引擎（补充：攻击面管理也有云厂商入场）

- <https://www.volcengine.com/product/asm> —— 官方页标注「互联网资产测绘（**建设中**）」，说明云厂商也在补 ASM。✅

> **本节要点**：国内 ASM/测绘的**通用漏斗 = 免费查询（引流）→ 会员订阅（¥199–¥3.6 万/月 或 $190–$10 万/年）→ 企业级 EASM/威胁情报平台（定制、无公开价）**。查询平台「按结果条数 / 点数」计费，企业平台按年 + 私有化/API。

---

## 4. 漏洞评估产品形态：扫描器 / 托管扫描（ASM）/ 漏洞管理平台

三者的**定位差异**与**交付物**：

| 形态 | 定位 | 典型部署 | 交付物（对外宣传） | 代表（官方页） |
|---|---|---|---|---|
| **扫描器（Scanner）** | 单点、按需的漏洞发现工具；一次扫描或周期扫描 | 本地工具 / 单机 / 软件 | **漏洞报告**（PDF/HTML，含漏洞明细、复现步骤、修复建议） | 长亭 **洞鉴 X-Ray** <https://www.chaitin.cn/xray>；知道创宇 ScanV；奇安信渗透测试服务 <https://www.qianxin.com/service/detail/pid/37> |
| **托管扫描 / ASM** | 从攻击者视角**持续**发现外部暴露面与风险，SaaS 为主 | SaaS（CNAME/域名接入）/ 私有化 | **资产台账 + 风险看板 + 告警 + API** | ZoomEye EASM <https://easm.zoomeye.org/>；长亭 **云图 Cloud Atlas** <https://www.chaitin.cn/cloudatlas>；华云安 ASM <https://www.huaun.com/>；火山引擎 ASM <https://www.volcengine.com/product/asm> |
| **漏洞管理平台（VM）** | 内外部资产漏洞的**全流程闭环**（发现→定级→派单→修复→验证），合规导向 | 私有化部署 / 混合 | **管理看板 + 工单闭环 + 报表 + 与 SOC/SIEM API 联动** | 华云安 **VM** <https://www.huaun.com/>；长亭 **鉴微 Insight** <https://www.chaitin.cn/insight>；微步 **NGTIP/TDP** <https://www.threatbook.cn/>；长亭 CTEM 方案 <https://www.chaitin.cn/solutions?tab=hot&catId=2> |

**三者关系**（官方资料口径）：
- **扫描器**解决「发现某个点有没有洞」，交付**报告**；
- **ASM（托管扫描）**解决「我到底有多少暴露面、哪些在被打」，交付**资产/风险看板 + 告警**；
- **漏洞管理平台**解决「发现之后谁来修、修没修完、怎么证明合规」，交付**闭环流程 + 报表 + API**。
- 长亭公开的 **CTEM（持续威胁暴露管理）** 方案把三者串成流程：日常扫描 → 应急响应 → 专项漏洞管理 → 优先级排序 → 闭环处置。✅ <https://www.chaitin.cn/solutions?tab=hot&catId=2>

---

## 5. 一个 CDN 公司的差异化切入点（3–5 条）

> 以下每条都标注 **依据**（已核实）或 **推断**（🔶 基于已核实事实的推理）。

### 5.1 已经站在客户流量路径上：安全可以「零部署」接入 ✅
CDN 天然位于 L7 请求路径与回源链路上，客户无需改架构即可叠加 WAF/Bot/DDoS。
- 依据：网宿 DDoS 云清洗官方页原文「**零部署、零改造、零运维**、一键接入」<https://www.wangsu.com/product/51>；阿里云 WAF 支持 **CNAME 接入** <https://help.aliyun.com/zh/waf/web-application-firewall-3-0/editions>；Cloudflare WAF/DDoS **Free 套餐即含** <https://www.cloudflare.com/plans/network-cdn>。

### 5.2 已持有域名 / 证书 / 回源配置等「已知资产」基线 ✅/🔶
CDN 控制台里本就存着客户的域名、SSL 证书、回源配置 —— 这正是资产测绘/ASM 最难做的「已知资产」起点，可直接复用为攻击面基线，省去从零测绘。
- 依据（资产存在）：Cloudflare Universal SSL、EdgeOne 免费证书、阿里云 CDN HTTPS 请求计费均为官方功能 <https://www.cloudflare.com/plans/network-cdn>、<https://cloud.tencent.com/document/product/1552/90437>、<https://www.aliyun.com/price/detail/cdn>。
- 🔶 推断：把上述资产自动导入 ASM 可形成「已知资产 → 未知资产扩散」的天然起点（厂商未公开表述此做法）。

### 5.3 已有节点分布与带宽储备，可直接复用为安全清洗/边缘安全节点 ✅
DDoS 清洗与边缘 WAF 需要大量分布式节点与带宽，CDN 厂商已具规模，边际成本低。
- 依据：网宿 DDoS「**全球 3000+ 安全防护节点、100+ 清洗中心，全网防护容量超 20Tbps**」<https://www.wangsu.com/product/51>；Cloudflare「**Unmetered DDoS Protection**」<https://www.cloudflare.com/plans/network-cdn>；EdgeOne「**Platform DDoS Protection / Unmetered Security Traffic**」<https://edgeone.ai/pricing>；白山云「1500+ 边缘节点、90 Tbps+ 带宽储备」<https://www.baishan.com/>。

### 5.4 已有计费、资源包与工单关系：安全可作为「增值计费项」随账卖 ✅
客户已在 CDN 账单/资源包/工单体系内，安全可作为**增值服务**直接挂账，无需新建商务/交付链路。
- 依据：阿里云 CDN 计费模型 = **基础服务（必选）+ 增值服务（可选，单独计费）** <https://help.aliyun.com/zh/cdn/product-overview/billing-overview>，且其 CDN WAF 就是**按 CDN 请求数挂账计费**的增值项 <https://www.aliyun.com/price/detail/cdn>；EdgeOne 用 **VAU 用量单元**把 Bot/规则做成套餐外增值计费 <https://cloud.tencent.com/document/product/1552/94156>；网宿在线商城支持「云分发及安全类免费试用 + 首购折扣」<https://online.wangsu.com/>。

### 5.5 数据面规模可反哺情报与资产画像 ✅/🔶
CDN 每天处理巨量请求，天然沉淀攻击流量、Bot 行为与资产指纹，是「安全资讯/情报 + 资产画像」的原始燃料。
- 依据：白山云官方「**每日处理请求 7600 亿次+**」<https://www.baishan.com/>；微步的核心资产正是**情报数据 + 社区**并据此卖出 NGTIP/API/TDP <https://www.threatbook.cn/>、<https://x.threatbook.com/v5/pricing>。
- 🔶 推断：把 CDN 侧攻击/流量数据加工为「情报内容」再导流到企业服务，是 CDN 独有的、纯安全厂商拿不到的样本源（这是本报告最主要的推断，未获任何厂商官方佐证）。

### 5.6（备选）出海 / 跨境场景是「加速 + 安全」打包的天然刚需 ✅
出海客户的 DDoS/CC/合规诉求与加速诉求同时出现，天然适合打包。
- 依据：网宿「出海安全加速解决方案」<https://www.wangsu.com/solution/360>；EdgeOne「Global Expansion to China」<https://edgeone.ai/solutions/global-to-china>；Cloudflare「China Network Access」（Custom 加购）<https://www.cloudflare.com/plans/network-cdn>。

---

## 6. 结论表：产品线 → 形态 → 计费 → 对 CDN 公司的可复制性 → 依据

| 产品线 | 形态 | 计费模式（已核实项加粗） | 可复制性 | 依据（官方链接） |
|---|---|---|---|---|
| **CDN 内嵌 WAF/DDoS（套餐制）** | 安全作为 CDN 套餐功能阶梯 | **Free/WAF/DDoS 含在套餐**；高级项 Custom | **高** | Cloudflare <https://www.cloudflare.com/plans/network-cdn>；EdgeOne <https://cloud.tencent.com/document/product/1552/94158>、<https://edgeone.ai/pricing> |
| **独立 WAF（订阅制）** | 独立 SaaS/WAF 实例，按版本 + QPS 扩展 | **基础版 ¥980/月、高级版 ¥3,880/月、企业版 ¥9,800/月、旗舰版 ¥29,800/月**；Bot ¥8,000–12,000/月 | 中 | 阿里云 <https://help.aliyun.com/zh/waf/web-application-firewall-3-0/editions>、<https://help.aliyun.com/en/waf/web-application-firewall-3-0/billing-description>；Akamai（无公开价）<https://www.akamai.com/products/security> |
| **独立 DDoS 高防** | 保底防护 + 弹性后付费 | **30Gbps ≈ ¥2.08 万/月；60Gbps ≈ ¥4.68 万/月；100Gbps ≈ ¥32.8 万/年**；原生企业版 100Mbps ¥46,800/月 | 中（需清洗节点/带宽） | 阿里云 <https://www.aliyun.com/price/detail/ddos>；EdgeOne 独立 DDoS <https://cloud.tencent.com/document/product/1552/94162> |
| **Zero Trust / SASE** | 席位制（user/month） | **$7/用户/月**（PAYG）；Free ≤50 用户；Contract 定制 | 中 | Cloudflare <https://www.cloudflare.com/plans/sase-zero-trust>；网宿 SASE <https://www.wangsu.com/product/109>、白山云 SASE <https://www.baishan.com/product-des/9.html> |
| **安全资讯/情报媒体** | 门户 + 社区 + 招聘 + 活动 | 广告/投放、会员、活动、商务合作；**价格多未公开** | 高（CDN 有现成客户与流量） | FreeBuf <https://www.freebuf.com/>、<https://m.freebuf.com/member>；安全客 <https://www.anquanke.com/> |
| **威胁情报社区→企业情报** | 免费社区 + 付费会员 + 企业情报平台/API | **社区会员 ¥468/6 个月起、¥798/2 个月起**；企业版「详询报价」 | 高（漏斗可复制） | 微步 <https://x.threatbook.com/v5/pricing>、<https://www.threatbook.cn/> |
| **网络空间测绘/查询平台** | 免费查询 + 会员 + 企业版 | **FOFA：个人 ¥199、专业 ¥999、商业 ¥9,999、企业版 ¥36,000/月起**；**ZoomEye：$190 / $1,090 / $10,990 / $100,000 每/年** | 高（最像「免费→付费」标准漏斗） | FOFA <https://fofa.info/vip>、<https://en.fofa.info/vip>；ZoomEye <https://www.zoomeye.ai/pricing> |
| **攻击面管理（ASM / EASM）** | SaaS 持续监测 / 私有化 | 企业定制、无公开价 | 高（CDN 资产数据是天然优势，见 5.2） | ZoomEye EASM <https://easm.zoomeye.org/>；长亭 云图 <https://www.chaitin.cn/cloudatlas>；华云安 <https://www.huaun.com/>；火山引擎 <https://www.volcengine.com/product/asm> |
| **漏洞扫描器** | 工具/软件，按需或周期扫描 | 商业版订阅（**无公开价**）；社区版免费引流 | 中 | 长亭 洞鉴 X-Ray <https://www.chaitin.cn/xray>；Xray 社区版 <https://xray.cool>；奇安信渗透测试 <https://www.qianxin.com/service/detail/pid/37> |
| **漏洞管理平台（VM）** | 私有化/混合，闭环流程 + 看板 + API | 项目制/定制（**无公开价**） | 中 | 华云安 <https://www.huaun.com/>；长亭 鉴微 <https://www.chaitin.cn/insight>；长亭 CTEM 方案 <https://www.chaitin.cn/solutions?tab=hot&catId=2> |
| **云防御 SaaS（免费引流）** | 免费云 WAF/CDN → 付费防护 | 免费版 + 付费版（**付费价未公开**） | **高**（与 CDN 能力最同构） | 知道创宇 云安全 <https://www.yunaq.com/>、云防御 <https://defense.yunaq.com/> |
| **企业安全全产品线** | 项目制/合约制 | **无公开价** | 低（非 CDN 基因） | 奇安信 <https://www.qianxin.com/product/index>；Akamai <https://www.akamai.com/products/security> |

---

## 7. 公开信息缺口清单（明确「找不到 / 未核实」）

> 按验收要求，以下**至少 2 处**为公开渠道确实无法核实的信息，全部标注来源与尝试方式：

1. **Akamai 安全产品定价 `[未核实]`** —— 官网 Pricing 导航「Security and Delivery」仅提供 `Contact Sales` 与 Free trials，**无任何公开标价**。（来源：<https://www.akamai.com/products/security>，Pricing 菜单原文）
2. **网宿科技安全产品定价 `[未核实]`** —— 官网（<https://www.wangsu.com/>）及产品页（DDoS 云清洗 <https://www.wangsu.com/product/51>、WAF <https://www.wangsu.com/product/52>）均无价目表；直连返回 HTTP 406（反爬），改用同 URL 渲染快照仍**未见价格**，仅见「按需付费」表述和商城「免费试用 / 首购 6 折」活动。
3. **白山云安全产品定价 `[未核实]`** —— <https://www.baishan.com/> 有完整安全产品页，但**无公开报价**。
4. **FreeBuf 会员 / 知识大陆定价 `[未核实]`** —— 官网 <https://www.freebuf.com/> 与会员中心 <https://m.freebuf.com/member> 均返回 HTTP 405（反爬拦截），**未读到公开价目**。
5. **360 Quake 会员 / 企业版定价 `[未核实]`** —— <https://quake.360.net/> 会员入口需登录，全网官方渠道**未找到公开定价页**。
6. **长亭科技、华云安、奇安信的产品定价 `[未核实]`** —— 三家官网产品/解决方案页均为「申请试用 / 立即咨询 / 提交需求」，**无公开价目**。
7. **腾讯云 EdgeOne 中国区「独立 DDoS 防护」具体单价 `[未核实]`** —— 计费概述指向独立文档 <https://cloud.tencent.com/document/product/1552/94162>，但**未在本次抓取中读取到其数值表**（页面为动态渲染）。
8. **FOFA 个人/专业/商业版「月付 vs 年付」的精确映射 🔶** —— 页面同时显示 `¥199` 与 `¥119/月`（及对应档位）两档，页面仅提供「月 / 年」切换；**两档与「月付 / 年付」的对应关系为推断**，未逐档切换核实。

---

### 附：本文件引用的官方域名一览

Cloudflare：`cloudflare.com`｜Akamai：`akamai.com`｜网宿：`wangsu.com`、`online.wangsu.com`｜白山云：`baishan.com`｜腾讯云：`cloud.tencent.com`、`edgeone.ai`｜阿里云：`aliyun.com`、`help.aliyun.com`｜FOFA：`fofa.info`｜ZoomEye：`zoomeye.ai`、`easm.zoomeye.org`、`zoomeye.org`｜360 Quake：`quake.360.net`、`360.net`｜微步：`threatbook.cn`、`x.threatbook.com`｜长亭：`chaitin.cn`、`xray.cool`｜华云安：`huaun.com`｜知道创宇：`yunaq.com`、`defense.yunaq.com`、`knownsec.com`｜奇安信：`qianxin.com`｜FreeBuf/斗象：`freebuf.com`、`vulbox.com`、`tophant.com`｜安全客：`anquanke.com`｜火山引擎：`volcengine.com`
