# 02 · 企业数据资产安全：法规、标准、技术栈与落地项目

> **本文定位**：给"网络安全 + 企业数据资产安全"方向的独立开发者/讲师用的**合规底座 + 工程清单**。
> 回答三个问题：① 做这个方向必须懂哪些法规标准（每条给原文链接）；② 数据分类分级到底怎么写成代码；③ 有哪些开源件可以直接拼出 MVP。
>
> **核实口径**：全部链接于 **2026-10-13** 现场抓取核验；日期、标准号、现行状态逐字取自该页面。
> 未能从一手页面确认的内容标 `[未核实]`。法规条文以**抓取当日的现行文本**为准（注意《网络安全法》2025 年修正后条文号已变，见 §1.1）。
> 本文是工程调研，**不构成法律意见**；合规结论需由法务/律师复核。

---

## 0. 一页速览（TL;DR）

**三根合规支柱**（一切数据安全产品的验收标准最终都落到这三条）：

| 支柱 | 要求 | 出处 |
|---|---|---|
| **分类分级** | 国家建立数据分类分级保护制度；按行业领域确定重要数据具体目录 | [数据安全法 第21条](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html)、[网络数据安全管理条例 第5条](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) |
| **日志留存** | 网络日志留存**不少于 6 个月**；个人信息/重要数据的对外提供与委托处理**处理情况记录至少保存 3 年** | [网络安全法 第23条(三)](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)、[网络数据安全管理条例 第12条](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)、[个人信息保护法 第56条](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html) |
| **跨境管控** | 达到阈值的数据出境须申报安全评估；重要数据出境一律评估 | [促进和规范数据跨境流动规定 第2、7条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) |

**五个必须知道的"现行版本"事实**（很容易写错，社交博客还在传播旧版）：

1. **《网络安全法》已于 2025-10-28 修正，修正决定自 2026-01-01 施行**；条文重新编号，"日志留存不少于六个月"从旧第 21 条变为**新第 23 条第（三）项**（[修改决定](http://www.npc.gov.cn/c2/c30834/202510/t20251028_449048.html)，[修正后全文](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)）。
2. **GB/T 43697-2024《数据安全技术 数据分类分级规则》现行**，2024-03-15 发布、2024-10-01 实施（[国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F0C385EDC38CBF277AEC021F23126ADE)）。
3. **ISO/IEC 27701:2019 已被 ISO/IEC 27701:2025 代替**（2019 版 2025-10-14 起 Withdrawn）（[27701:2025](https://www.iso.org/standard/27701)、[27701:2019 状态](https://www.iso.org/standard/71670.html)）。
4. **OWASP API Security Top 10 现行版本仍是 2023 版**（[官方清单页](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)）；但 Web 版 **OWASP Top 10 已更新到 2025 版**（[官方项目页](https://owasp.org/projects/top-ten)）。
5. **NIST SP 800-53 仍是 Rev.5**，但已在 2025-08-27 发布补丁 **Release 5.2.0**（[Rev.5 官方页](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final)）。

**最小可行产品方向**：先做"**分类分级规则引擎 + 元数据台账**"（§3、§5 项目 2）——它是所有后续产品（DLP、DSPM、脱敏、出境台账）的公共前置。详见 §5。

---

## 1. 法规

### 1.1 四部法律（全国人大常委会）

#### 《中华人民共和国网络安全法》

| 项 | 值 |
|---|---|
| 通过 | 2016-11-07（第十二届全国人大常委会第二十四次会议） |
| 修正 | **2025-10-28**（第十四届全国人大常委会第十八次会议《关于修改〈中华人民共和国网络安全法〉的决定》） |
| 施行 | 原法自 **2017-06-01** 施行；**2025 修正决定自 2026-01-01 起施行**（现行版本） |
| 原文 | [修正后全文（中国人大网转载）](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm) ／ [修改决定](http://www.npc.gov.cn/c2/c30834/202510/t20251028_449048.html) |

对安全产品开发者的关键条款（条文号为**修正后**编号）：

- **第 23 条**：国家实行网络安全等级保护制度。网络运营者应履行五项义务，其中
  - 第（三）项：**"采取监测、记录网络运行状态、网络安全事件的技术措施，并按照规定留存相关的网络日志不少于六个月"** → 直接决定审计日志的**存储周期与完整性**要求；
  - 第（四）项："采取**数据分类**、重要数据备份和加密等措施" → 分类分级义务在网安法层的根。
  （[第23条原文](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)）
- **第 24 条**：网络产品、服务应符合国家标准强制性要求；发现安全缺陷/漏洞应**立即补救、告知用户并报告**；应在约定/规定期限内持续提供安全维护。
- **第 25 条**：**网络关键设备和网络安全专用产品**须按国家标准强制性要求，**经具备资格机构安全认证合格或安全检测符合要求后方可销售或提供**；目录由网信部门会同有关部门制定。→ 若你的产品被列入目录，就是**准入问题**，不是自律问题（[第25条](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)）。
- **第 39 条**：CII 运营者在境内运营中收集和产生的**个人信息和重要数据应当在境内存储**；确需出境的须通过网信部门组织的**安全评估**。
- **第 61 条（罚则）**：不履行第 23、27 条义务一般 1 万–5 万；**造成大量数据泄露、CII 丧失局部功能等严重后果：50 万–200 万**；**造成 CII 丧失主要功能等特别严重后果：200 万–1000 万**（对直接责任人 20 万–100 万）。

#### 《中华人民共和国数据安全法》

| 项 | 值 |
|---|---|
| 通过 / 公布 | 2021-06-10（主席令第八十四号） |
| 施行 | **2021-09-01**（第 55 条） |
| 现行状态 | 有效，**未经修正** |
| 原文 | [中国人大网全文](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html) |

- **第 21 条**：**国家建立数据分类分级保护制度**；国家数据安全工作协调机制统筹协调制定**重要数据目录**；对"国家核心数据"实行更严格管理；各地区、各部门确定本行业领域重要数据具体目录。→ 这是整个分类分级赛道的法源。
- **第 27 条**：建立健全**全流程数据安全管理制度**；利用网络开展数据处理活动应在**等级保护制度基础上**履行数据安全义务；**重要数据处理者应明确数据安全负责人和管理机构**。
- **第 30 条**：**重要数据处理者应按规定对其数据处理活动定期开展风险评估，并向主管部门报送风险评估报告**。
- **第 31 条 / 第 36 条**：CII 运营者重要数据出境适用《网络安全法》；**非经主管机关批准，境内组织、个人不得向外国司法或执法机构提供存储于境内的数据**。
- **第 45 条（罚则）**：不履行第 27、29、30 条义务一般 5 万–50 万；造成大量数据泄露等严重后果 **50 万–200 万**；违反国家核心数据管理制度 **200 万–1000 万**。**第 46 条**：违规向境外提供重要数据，情节严重 **100 万–1000 万**。

#### 《中华人民共和国个人信息保护法》（PIPL）

| 项 | 值 |
|---|---|
| 通过 / 公布 | 2021-08-20（主席令第九十一号） |
| 施行 | **2021-11-01**（第 74 条） |
| 现行状态 | 有效，**未经修正** |
| 原文 | [中国人大网全文](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html) |

- **第 51 条（产品功能清单）**：个人信息处理者应采取的措施，逐项就是产品需求：
  （一）内部管理制度和操作规程；（二）**对个人信息实行分类管理**；（三）**加密、去标识化**等安全技术措施；（四）**合理确定操作权限**；（五）应急预案。
- **第 52 条**：达到网信部门规定数量的处理者应**指定个人信息保护负责人**。
- **第 55 条**：**必须事前做个人信息保护影响评估（PIA）**的五种情形：处理敏感个人信息；自动化决策；委托处理/向其他处理者提供/公开；向境外提供；其他对个人权益有重大影响的活动。
- **第 56 条**：**"个人信息保护影响评估报告和处理情况记录应当至少保存三年"** → 和网数条例第 12 条的 3 年叠加，形成"**3 年留存**"这条硬线。
- **第 38 / 40 条**：向境外提供个人信息的三种合法路径（安全评估 / 保护认证 / 标准合同）；CII 运营者与达到规定数量的处理者须**境内存储**，确需出境须通过安全评估。
- **第 66 条（罚则）**：情节严重处**五千万元以下或上一年度营业额 5% 以下**罚款，对直接责任人 10 万–100 万。

#### 《中华人民共和国密码法》

| 项 | 值 |
|---|---|
| 通过 / 公布 | 2019-10-26（主席令第三十五号） |
| 施行 | **2020-01-01**（第 44 条） |
| 现行状态 | 有效，**未经修正** |
| 原文 | [中国人大网全文](http://www.npc.gov.cn/npc/c1773/c1848/c21114/c36794/c36798/201910/t20191028_301735.html) ／ [国家密码管理局转载](https://www.oscca.gov.cn/sca/xwdt/2019-10/28/content_1057251.shtml) |

- **第 26 条**：涉及国家安全、国计民生、社会公共利益的商用密码产品，应依法列入**网络关键设备和网络安全专用产品目录**，**由具备资格的机构检测认证合格后方可销售或提供**。
- **第 27 条**：要求使用商用密码保护的关键信息基础设施，运营者应**自行或委托开展商用密码应用安全性评估（密评）**；采购可能影响国家安全的商用密码产品/服务须通过**国家安全审查**。
- **第 35–37 条（罚则）**：检测认证机构违规最高罚违法所得 1–3 倍（不足 30 万时罚 10 万–30 万）并可吊销资质；CII 运营者未按要求使用商用密码或未开展密评，最高 **10 万–100 万**；使用未通过安全审查的产品按**采购金额 1–10 倍**罚款。

> **对 KMS/加密类产品的意义**：面向国内政企客户时，"国密算法（SM2/SM3/SM4）+ 密评 + 商用密码产品目录"是硬约束，不是营销选项。

### 1.2 行政法规与部门规章

#### 《网络数据安全管理条例》（国务院令第 790 号）★ 本领域"最实用"的一部

| 项 | 值 |
|---|---|
| 发文字号 | 国令第 790 号 |
| 成文 / 公布 | 成文 2024-09-24；**发布 2024-09-30**（2024-08-30 国务院第 40 次常务会议通过） |
| 施行 | **2025-01-01**（第 64 条） |
| 原文 | [中国政府网全文](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) |

适用要点（对产品开发者）：

- **义务主体界定｜第 62 条（三）**：**"网络数据处理者，是指在网络数据处理活动中自主决定处理目的和处理方式的个人、组织。"** → 判定标准是**自主决定处理目的和方式**，而不是"是否接触数据"。SaaS 厂商、工具厂商是否落入义务，取决于这一点。
- **漏洞响应时限｜第 10 条**：产品/服务发现安全缺陷、漏洞应立即补救、告知用户并报告；**涉及危害国家安全、公共利益的应当在 24 小时内向有关主管部门报告** → 这是产品里"事件上报"功能的 SLA 参数。
- **留存期限｜第 12 条**：向其他处理者提供、委托处理个人信息和重要数据，**处理情况记录应当至少保存 3 年**。
- **服务 CII/国家机关的特殊约束｜第 16 条**：为其提供服务时，**未经委托方同意不得访问、获取、留存、使用、泄露或向他人提供网络数据，不得对网络数据进行关联分析** → 直接影响多租户架构：**默认禁关联分析、禁跨租户留存**。
- **重要数据目录｜第 29 条**：国家数据安全工作协调机制统筹制定重要数据目录；各地区、各部门确定本地区/本部门/本行业领域的重要数据具体目录；**网络数据处理者应当按国家有关规定识别、申报重要数据**；国家鼓励使用数据标签标识技术产品。
- **风险评估｜第 31 条**：**重要数据处理者在提供、委托处理、共同处理重要数据前应进行风险评估**；**第 33 条**：重要数据处理者应**每年度**开展风险评估并向省级以上主管部门**报送风险评估报告**。
- **规模化门槛｜第 28 条**：处理**1000 万人以上个人信息**者，适用重要数据处理者的部分规定（第 30、32 条）。
- **跨境｜第 35–37 条**：第 35 条列举可向境外提供个人信息的八类条件；**第 37 条**：**重要数据出境须通过国家网信部门组织的数据出境安全评估**。
- **禁止性条款｜第 39 条**：任何个人、组织不得提供**专门用于破坏、避开技术措施**的程序、工具 → 做"数据脱敏/反脱敏""绕过访问控制"类功能时的红线。
- **罚则**：第 55 条（拒不改正/情节严重）**100 万元以下**并可责令停业、吊销执照；第 56 条（违反国家安全审查）**100 万–1000 万**；第 57 条（违反重要数据相关规定，造成大量数据泄露等严重后果）**50 万–200 万**。

#### 《关键信息基础设施安全保护条例》（国务院令第 745 号）

| 项 | 值 |
|---|---|
| 发文字号 | 国令第 745 号 |
| 成文 / 公布 | 成文 2021-07-30；**发布 2021-08-17**（2021-04-27 国务院第 133 次常务会议通过） |
| 施行 | **2021-09-01**（第 51 条） |
| 原文 | [中国政府网全文](https://www.gov.cn/zhengce/content/2021-08/17/content_5631671.htm) |

- **第 2 条 / 第 10 条（认定）**：CII 覆盖公共通信和信息服务、能源、交通、水利、金融、公共服务、电子政务、国防科技工业等；**由保护工作部门按认定规则组织认定并通知运营者**。→ 客户是不是 CII，你通常问不到，**必须按"可能被认定为 CII"来做设计**。
- **第 14 / 15 条**：运营者应设**专门安全管理机构**，对负责人和关键岗位人员做**安全背景审查**；专门机构职责含"履行个人信息和数据安全保护责任"。
- **第 17 条**：运营者应**每年至少进行一次网络安全检测和风险评估**，并向保护工作部门报送。
- **第 19 / 20 条**：运营者应**优先采购安全可信的网络产品和服务**；可能影响国家安全的采购须通过**网络安全审查**；与产品服务提供者签订**安全保密协议**。
- **第 31 条**：**未经批准或授权，任何个人和组织不得对 CII 实施漏洞探测、渗透性测试等活动** → 这条是"不做渗透测试服务交付"这条路线选择在法律侧的支撑。
- **罚则**：第 39 条（运营者违规）10 万–100 万；第 41 条（采购可能影响国家安全的产品未做安全审查）**采购金额 1–10 倍**。

#### 《促进和规范数据跨境流动规定》（国家互联网信息办公室令第 16 号）

| 项 | 值 |
|---|---|
| 发文字号 | 国家互联网信息办公室令 第 16 号（2023-11-28 第 26 次室务会议审议通过） |
| 公布 / 施行 | **2024-03-22 公布，自公布之日起施行**（第 14 条） |
| 原文 | [中国网信网全文](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) |

**数据出境安全评估触发条件（这是做"出境台账/流量识别"产品的判定表）**：

| 情形 | 依据 | 要求 |
|---|---|---|
| 非 CII，当年累计出境个人信息 **< 10 万人**（不含敏感） | [第 5 条（四）](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | **豁免**（不需评估/标准合同/认证） |
| 非 CII，累计 **10 万–100 万人**（不含敏感），或敏感个人信息 **< 1 万人** | [第 8 条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | 订立**标准合同**或通过**个人信息保护认证** |
| **CII 运营者**出境个人信息或重要数据 | [第 7 条（一）](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | **申报数据出境安全评估** |
| 非 CII，出境**重要数据**，或累计 **≥100 万人**（不含敏感），或敏感 ≥ **1 万人** | [第 7 条（二）](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | **申报数据出境安全评估** |
| 国际贸易、跨境运输、学术合作、跨国生产制造和市场营销等活动中产生的**不含个人信息或重要数据**的数据出境 | [第 3 条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | 豁免 |
| 境外收集产生的个人信息，入境处理后回传，处理过程未引入境内个人信息/重要数据 | [第 4 条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | 豁免 |
| 自贸区负面清单外的数据出境 | [第 6 条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm) | 免予评估/标准合同/认证 |

其他要点：

- **第 2 条（重要数据口径，极其重要）**："数据处理者应当按照相关规定识别、申报重要数据。**未被相关部门、地区告知或者公开发布为重要数据的，数据处理者不需要作为重要数据申报数据出境安全评估。**" → 实务上，"重要数据"以**被告知/公开目录**为准，这直接决定产品的"重要数据识别"是**本地推断**还是**目录比对**。
- **第 9 条**：通过安全评估的结果**有效期 3 年**，届满前 60 个工作日可申请延长 3 年。
- **第 10 / 11 条**：出境须履行告知、**单独同意**、PIA 等义务；须采取技术措施保障出境安全，发生或可能发生数据安全事件及时向省级以上网信部门和主管部门报告。
- **第 13 条（衔接）**：与《数据出境安全评估办法》（网信办令第 11 号，**2022-07-07 公布**）、《个人信息出境标准合同办法》（网信办令第 13 号，**2023-02-22 公布**）不一致的，**适用本规定**。
- **第 12 条**：本规定未自设罚款，发现风险要求整改，拒不改正或造成严重后果的**依法追究法律责任**（援引上位法）。

### 1.3 义务 → 产品功能的映射（开发者视角）

这张表是本文最该被直接使用的一节：**左边是法定义务，右边是你的产品必须实现的机制**。

| 法定义务 | 法条（一手链接） | 产品必须实现 |
|---|---|---|
| 数据分类分级 | [数安法 21](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html)、[网安法 23(四)](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)、[网数条例 5](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 分类分级引擎 + 字段级台账 + 级别变更留痕（§3） |
| 重要数据目录识别与申报 | [数安法 21](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html)、[网数条例 29](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 重要数据候选清单导出（可对接到行业目录格式） |
| 日志留存 ≥ 6 个月 | [网安法 23(三)](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm) | 日志采集/存储 ≥ 180 天 + 完整性校验（防篡改） |
| 处理情况记录 ≥ 3 年 | [网数条例 12](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)、[个保法 56](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html) | 数据流转/共享/委托处理台账，保留 3 年 |
| 定期风险评估 + 报送 | [数安法 30](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html)、[网数条例 31/33](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 年度评估报告生成（对齐 GB/T 45577-2025 方法） |
| 跨境评估触发判定 | [跨境规定 5/7/8](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm)、[网安法 39](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm) | 出境目的地识别 + 当年累计人数计量 + 阈值告警 |
| 个人信息处理者义务 | [个保法 51](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html)、[网数条例 21/22/27](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 加密/去标识化/最小权限/单独同意/PIA 支持/合规审计 |
| 1000 万人以上个人信息 | [网数条例 28](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 个人信息主体数量统计与阈值告警 |
| 24 小时漏洞/事件报告 | [网数条例 10](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 漏洞与事件工单 + 上报时限倒计时 |
| 不得留存/关联分析客户数据 | [网数条例 16](https://www.gov.cn/zhengce/content/202409/content_6977766.htm) | 多租户强隔离；关联分析默认关闭、需显式授权 |
| 产品准入（认证/检测） | [网安法 25](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)、[密码法 26](http://www.npc.gov.cn/npc/c1773/c1848/c21114/c36794/c36798/201910/t20191028_301735.html) | 若产品落入目录：走检测认证，而不是只写文档 |
| 国密与密评 | [密码法 27](http://www.npc.gov.cn/npc/c1773/c1848/c21114/c36794/c36798/201910/t20191028_301735.html) | 支持 SM2/SM3/SM4；KMS 侧可导出密评材料 |
| CII 年度检测评估 | [CII 条例 17](https://www.gov.cn/zhengce/content/2021-08/17/content_5631671.htm) | 面向 CII 客户的能力证明与年度评估模板 |
| 不得未授权渗透测试 | [CII 条例 31](https://www.gov.cn/zhengce/content/2021-08/17/content_5631671.htm) | 产品内所有扫描能力必须"客户书面授权 + 范围白名单"前置 |

---

## 2. 国家标准与主流框架（核实到页面）

### 2.1 中国标准

| 标准号 | 名称 | 发布 | 实施 | 现行状态 | 一手链接 | 对做产品有什么用 |
|---|---|---|---|---|---|---|
| **GB/T 22239-2019** | 信息安全技术 网络安全等级保护基本要求（等保 2.0） | 2019-05-10 | 2019-12-01 | **现行**（2025-05-30 复审结论"继续有效"）；全部代替 GB/T 22239-2008 | [国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=BAFB47E8874764186BDB7865E8344DAF) | 客户最常引用的验收基线；安全产品的"控制项 → 功能项"映射表来源 |
| **GB/T 43697-2024** | 数据安全技术 数据分类分级规则 | 2024-03-15 | 2024-10-01 | **现行**（首版，归口 TC260） | [国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F0C385EDC38CBF277AEC021F23126ADE) | **分类分级引擎的算法本体**，见 §3 |
| **GB/T 37988-2019** | 信息安全技术 数据安全能力成熟度模型（DSMM） | 2019-08-30 | 2020-03-01 | **现行**（首版） | [国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=3CFD5E5A14C24D303EA1E139E6EB75C8) | 做"能力评估/成熟度诊断"类产品的评分框架 |
| **GB/T 35273-2020** | 信息安全技术 个人信息安全规范 | 2020-03-06 | 2020-10-01 | **现行**（2026-01-28 复审结论"修订"，即已列入修订计划）；全部代替 2017 版 | [国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=4568F276E0F8346EB0FBA097AA0CE05E) | 个人信息清单/授权同意/去标识化的具体条目池 |
| **GB/T 41479-2022** | 信息安全技术 网络数据处理安全要求 | 2022-04-15 | 2022-11-01 | **现行**（首版） | [国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=3E1EA8F7F96CB0CCCD8C98BE537E3A66) | 网络数据处理活动的通用安全要求；做数据处理平台的对照表 |
| **JR/T 0197-2020** | 金融数据安全 数据安全分级指南 | 2020-09-23 | 2020-09-23（发布即实施） | **现行**（金融行业标准，归口全国金融标准化技术委员会） | [全国标准信息公共服务平台](https://std.samr.gov.cn/hb/search/stdHBDetailed?id=B081D125A6762DB8E05397BE0A0A5EA7) ／ [人民银行金融标准全文公开系统](https://cfstc.pbc.gov.cn/bzgk/detail?bzId=1873&id=0) | **金融行业五级分级**，是"企业分级 ↔ 国标分级"映射必须处理的第二套口径 (§3.4) |
| **GB/T 45577-2025** | 数据安全技术 数据安全风险评估方法 | 2025-04-25 | 2025-11-01 | **现行** | [全国标准信息公共服务平台](https://std.samr.gov.cn/gb/search/gbDetailed?id=33D40F1161195D92E06397BE0A0A5B93) ／ [TC260 全文页](https://www.tc260.org.cn/tc260/xwdt1/202508/74cf0d7029234268a356a46170ada4b6.shtml) | **落实数安法 30 条 / 网数条例 33 条年度评估的方法学**，做评估报告自动化的直接依据 |

> 注：`GB/T 43697-2024`、`GB/T 22239-2019` 等的**标准全文**需在"国家标准全文公开系统"的**在线预览**中查看（页面本身只给号/名/日期/状态）；本表链接均已现场核验可达。

### 2.2 国际标准与框架

| 标准/框架 | 当前版本 | 官方日期 | 一手链接 | 备注 |
|---|---|---|---|---|
| **ISO/IEC 27001** | **2022**（Edition 3） | 2022-10-25 发布（生命周期 60.60） | [iso.org/standard/27001](https://www.iso.org/standard/27001) | 代替 27001:2013；有修正案 27001:2022/Amd 1:2024 |
| **ISO/IEC 27701** | **2025**（Edition 2） | 2025-10-14 发布 | [iso.org/standard/27701](https://www.iso.org/standard/27701) | **2019 版已于 2025-10-14 被代替（Withdrawn）**：[27701:2019 状态页](https://www.iso.org/standard/71670.html) |
| **NIST SP 800-53** | **Rev. 5**（+ 补丁 Release 5.2.0） | Rev.5 2020-09（含 2020-12-10 更新）；**5.2.0 于 2025-08-27 发布** | [SP 800-53 Rev.5](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final) | 不是新 Revision，是同一 Rev.5 的小版本补丁 |
| **NIST CSF** | **2.0**（NIST CSWP 29） | 2024-02-26 | [CSF 2.0 官方页](https://csrc.nist.gov/pubs/cswp/29/the-nist-cybersecurity-framework-csf-20/final) | 治理（GV）职能是本版新增 |
| **NIST Privacy Framework** | **1.0** | 2020-01-16 | [nist.gov/privacy-framework](https://www.nist.gov/privacy-framework) | 1.1 目前仍是 Initial Public Draft（[CSWP 40 ipd](https://csrc.nist.gov/pubs/cswp/40/nist-privacy-framework-11/ipd)），故 1.0 仍为现行正式版 |
| **NIST SP 800-207** | Final | 2020-08-11 | [SP 800-207](https://csrc.nist.gov/pubs/sp/800/207/final) | 零信任架构（ZTA）抽象定义与部署模型 |
| **NIST SP 800-218（SSDF）** | **1.1** | 2022-02-03 | [SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final) | 安全开发框架；做"产品自身安全"的证据链 |
| **OWASP API Security Top 10** | **2023**（当前版） | 2023-07-03 | [API Top 10 – 2023](https://owasp.org/API-Security/editions/2023/en/0x11-t10/) | 未发现 2024/2025/2026 新版公告 `[未核实]` |
| **OWASP Top 10（Web）** | **2025**（第 8 版） | 官方仅给"2025 年 11 月第一周"计划 `[未核实]`精确日 | [OWASP Top 10 项目页](https://owasp.org/projects/top-ten) | 项目页逐字："The most current released version is the OWASP Top 10 2025" |
| **OWASP ASVS** | **5.0.0** | 2025-05-30 | [ASVS 项目页](https://owasp.org/projects/asvs) | 应用安全验证标准，取代 4.0.x |
| **OWASP SAMM** | **2.0** | 2020-01-31 | [SAMM 模型页](https://owaspsamm.org/model/) | 5 大业务功能 / 15 项安全实践 |
| **OWASP Data Security Top 10** | **2025**（DATA1:2025 … DATA10:2025） | 精确发布日 `[未核实]` | [项目页](https://owasp.org/projects/data-security-top-10)（GitHub [OWASP/DVDS](https://github.com/OWASP/DVDS)） | **与本方向最贴的一套风险分类**：注入攻击、认证与访问控制失效、数据泄露、勒索软件、内部威胁、弱加密、不安全数据处理、第三方风险、数据资产盘点、不合规 |

**OWASP API Security Top 10（2023）十项**（[官方清单页](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)）：

| # | 名称 | 中文 |
|---|---|---|
| API1:2023 | Broken Object Level Authorization | 对象级授权失效（BOLA） |
| API2:2023 | Broken Authentication | 身份认证失效 |
| API3:2023 | Broken Object Property Level Authorization | 对象属性级授权失效 |
| API4:2023 | Unrestricted Resource Consumption | 不受限制的资源消耗 |
| API5:2023 | Broken Function Level Authorization | 功能级授权失效 |
| API6:2023 | Unrestricted Access to Sensitive Business Flows | 对敏感业务流的无限制访问 |
| API7:2023 | Server Side Request Forgery | 服务端请求伪造（SSRF） |
| API8:2023 | Security Misconfiguration | 安全配置错误 |
| API9:2023 | Improper Inventory Management | 资产管理不当 |
| API10:2023 | Unsafe Consumption of APIs | 不安全的 API 消费 |

> **对本方向的含义**：API1/API3/API5 全是**授权粒度**问题——这正是"数据资产安全"与"传统边界安全"的分界；API9（资产管理不当）说明**数据/接口盘点本身就是安全能力**。

### 2.3 标准之间的关系（一句话版）

- **法律给义务**（数安法 21/30、网数条例 5/29/33、网安法 23）→ **GB/T 43697-2024 给"怎么分"**（通用规则 + 重要数据识别指南）→ **各行业主管发布行业细则**（如能源、金融、教育、民航）→ **GB/T 45577-2025 给"怎么评风险"** → **GB/T 37988-2019（DSMM）给"能力到了几级"** → **GB/T 22239-2019（等保 2.0）给"技术措施基线"**。
- 国际侧：**ISO/IEC 27001:2022**（管理体系）＋ **ISO/IEC 27701:2025**（隐私管理）覆盖"体系认证"需求；**NIST CSF 2.0 / SP 800-53 Rev.5** 覆盖控制项清单；**OWASP** 系列覆盖应用与 API 层的具体缺陷。

---

## 3. 数据分类分级：如何写成可执行的规则引擎

这一节把 **GB/T 43697-2024** 的规范内容还原成**可编程的数据结构与算法**，并给出可直接建表的元数据 schema。
（标准正文引用均指 GB/T 43697-2024，标准本身见 [国标全文公开系统](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F0C385EDC38CBF277AEC021F23126ADE)。）

### 3.1 先把国标的"算法"讲清楚

**A. 分类（第 5 章）**：`先行业领域 → 再业务属性`

- 行业领域（5.1 a））：工业、电信、金融、能源、交通运输、自然资源、卫生健康、教育、科学数据…（**第一层就是 9+ 个枚举值**）
- 业务属性（5.1 b））：9 种可选维度 —— 业务领域、责任部门、**描述对象**、流程环节、**数据主体**、内容主题、数据用途、数据处理、数据来源。
- 标准给出两张可直接当字典用的参考表：
  - 附录 A.1 按描述对象：**用户数据 / 业务数据 / 经营管理数据 / 系统运维数据**（4 类，含定义与示例）
  - 附录 A.2 按数据主体：**公共数据 / 组织数据 / 个人信息**（3 类）
  - 附录 B：个人信息一级/二级类别 + 典型示例（24+ 个二级类，含**金融账户信息、身份鉴别信息、行踪轨迹信息、生物识别信息**等）→ **这份表可 1:1 转成检测规则库**
- 5.1 c）强制要求：法律法规有专门管理要求的数据类别（如个人信息）**必须单独识别**。

**B. 分级（第 6 章）**：四步流水线

```
① 确定分级对象  →  ② 分级要素识别  →  ③ 数据影响分析  →  ④ 综合确定级别
   (6.2 a)          (6.2 b / 6.3)      (6.4.1 / 6.4.2)     (6.5 / 6.6)
```

- **① 分级对象**（6.2 a）：数据项（数据库表的某个字段）、数据集（表/多行记录）、衍生数据、跨行业领域数据。
- **② 分级要素（6.3，8 个）**：

  | 要素 | 定性/定量 | 标准给出的可识别子因素 |
  |---|---|---|
  | 领域 | 定性 | 行业领域、业务条线、流程环节、内容主题 |
  | 群体 | 定性 | 人群、组织、网络/信息系统、资源物资 |
  | 区域 | 定性 | 行政区划、特定地区 |
  | **精度** | 定量 | 数值精度、空间精度、时间精度 |
  | **规模** | 定量 | 数据存储量、群体规模、区域规模、领域规模、生产加工能力 |
  | 深度 | 定性（衍生数据专用） | 统计、关联、挖掘、融合的刻画程度 |
  | **覆盖度** | 定量 | 对领域/群体/区域/时段的覆盖占比与分布 |
  | 重要性 | 定性 | 经济/政治/文化/社会/生态文明建设中的重要程度 |

- **③ 影响分析**：**6 类影响对象** × **3 档影响程度**
  - 影响对象（6.4.1）：国家安全、经济运行、社会秩序、公共利益、组织权益、个人权益
  - 影响程度（6.4.2）：特别严重危害、严重危害、一般危害
  - **基准切换规则**：影响对象是国家安全/经济运行/社会秩序/公共利益时，以国家、社会或行业领域**整体利益**为判断基准；仅涉及组织或个人权益时，以**该组织/个人**权益为基准。
- **④ 级别确定（6.5 表 1）**——**这是整个引擎的核心查表函数**：

  | 影响对象 ↓ / 影响程度 → | 特别严重危害 | 严重危害 | 一般危害 |
  |---|---|---|---|
  | 国家安全 | 核心数据 | 核心数据 | 重要数据 |
  | 经济运行 | 核心数据 | 重要数据 | 一般数据 |
  | 社会秩序 | 核心数据 | 重要数据 | 一般数据 |
  | 公共利益 | 核心数据 | 重要数据 | 一般数据 |
  | 组织权益、个人权益 | 一般数据 | 一般数据 | 一般数据 |

  说明：若影响**大规模**个人或组织权益，影响对象可能同时命中国家安全/经济运行/社会秩序/公共利益 → 必须按**就高从严**重判。

**C. 综合确定级别（6.6）** —— 7 条必须实现的算子：

1. 按 6.5 识别核心/重要/一般。
2. 重要数据识别在 6.5 b）基础上**必须执行附录 G（规范性）**。
3. **就高从严**：多要素、多影响对象时取最高级别。
4. **数据集级别 = `max(所含数据项级别)`**，但需考虑规模变化可能要求**调高**。
5. 一般数据如需细化，参考**附录 H**。
6. **衍生数据**按就高从严 + 加工深度调整（**附录 I**）。
7. 跨行业领域数据按来源行业规则定级；融合加工产生的按衍生数据定级。
8. 数据级别应**动态更新**（**附录 J**）。

**D. 附录 G：重要数据识别指南（规范性，17 条 a–r）** —— 这是**规则引擎最高价值的规则源**，因为它是"规范性"而非"资料性"。摘出可直接编码的部分：

| 因素 | 触发条件（摘要） | 可程序化的信号 |
|---|---|---|
| a） | 未公开的领陆/领水/领空数据 | 领域标签 + 未公开标记 |
| b） | 满足一定精度指标的地理数据；战略物资产能/储备量数据 | **精度阈值**（如优于 100m 的坐标）|
| c） | 支撑 CII 所在行业核心业务运行的数据 | 客户/系统属于 CII 行业目录 |
| e） | 重点目标/重要场所物理安全保护情况、未公开地理目标位置；施工图、内部结构、安防情况 | 文档类型（图纸/结构）+ 场所标签 |
| f） | 国家科技创新重大成果、出口管制物项的设计原理/工艺流程/源代码/集成电路布图/重要参数/实验数据 | **文件名/字段名关键词** + 未公开 |
| g） | **CII 的系统配置信息、系统拓扑、应急预案、测评、运行维护、审计日志**；核心软硬件资产与供应链信息 | 资产发现结果本就是重要数据 |
| h） | 未公开的攻击方法/工具制作方法；**政府、军工等敏感客户清单**；未公开的产品服务采购情况、未公开重大漏洞 | CRM 客户清单 + 客户行业标签 |
| k） | 核电站设计图、运行情况 | 行业标签 |
| o） | 未公开的统计数据、重点企业商业秘密 | 表/字段语义 + 公开状态 |
| q）r） | 兜底：可能影响国家安全/经济运行/社会秩序/公共利益 | 兜底规则 + 人工复核 |

标准结论：**"具备以上因素之一的数据，可被识别为重要数据。"**

**E. 附录 H：一般数据分级（资料性）** —— 提供 **4 级 / 3 级 / 2 级**三套参考，且给出**特定类型的最低参考级别**（非常重要，可直接硬编码）：

在 **4 级框架**下：
- **敏感个人信息 ≥ 4 级**，**一般个人信息 ≥ 2 级**
- 组织内部员工个人信息 ≥ 2 级
- **去标识化的个人信息 ≥ 2 级**
- 个人标签信息 ≥ 2 级
- 有条件开放/共享的公共数据 ≥ 2 级；**禁止开放/共享的公共数据 ≥ 4 级**

在 3 级框架下：敏感个人信息 ≥ 3 级，一般个人信息 ≥ 2 级，禁止开放/共享的公共数据 ≥ 3 级。
在 2 级框架下：敏感个人信息 ≥ 2 级，禁止开放/共享的公共数据 ≥ 2 级。

**F. 附录 I：衍生数据分级（资料性）** —— 加工程度分类：**原始数据 / 脱敏数据 / 标签数据 / 统计数据 / 融合数据**，并给出升降级方向：

- **脱敏数据**：级别可比原始数据**降低**（= 脱敏是"降级手段"，可写成算子）
- **标签数据**：可比原始**降低或升高**
- **统计数据**：可比原始**降低或升高**（例：未公开的、影响国家宏观调控能力的行业统计 → 更高级别）
- **融合数据**：汇聚多维关联挖掘后可**升高**；降低标识化程度后可**降低**

**G. 附录 J：动态更新情形（资料性，9 类触发）** —— 直接对应"事件驱动重算"的需求：

数据规模变化；时效性/规模/应用场景/加工方式显著变化；多原始数据直接合并；部分数据合并成新数据；汇聚融合形成新类别；脱敏/删除关键字段/去标识化/匿名化；**发生数据安全事件导致敏感性变化**；国家或行业主管部门要求；其他需变更情形。

### 3.2 引擎设计：识别层 → 分拣层 → 映射层

```
                        ┌─────────────── 元数据/采样 输入 ───────────────┐
                        │  列名·类型·注释·行数·基数·样本指纹(不存原值)   │
                        └───────────────────┬───────────────────────────┘
                                            ▼
 ┌──────────────────────── ① 识别层 Detector ─────────────────────────┐
 │  D1 正则/校验器  身份证(GB 11643 校验位)、手机号、银行卡(Luhn)、    │
 │                  统一社会信用代码、IPv4/IPv6、邮箱、经纬度           │
 │  D2 命名语义      列名/表名/注释分词 → 语义标签(中文+英文同义词表)   │
 │  D3 PII 实体识别  NER / 词典匹配(姓名/地址/机构)                     │
 │  D4 字典/枚举     行业码、密级标记、文件路径关键词(图纸/源码/客户)    │
 │  D5 统计推断      基数/唯一性/长度分布/格式一致性 → 判断"是不是标识符"│
 └────────────────────────────┬────────────────────────────────────────┘
                              ▼  evidence[]: {rule_key, 命中位置, 计数, 采样率, 置信度}
 ┌──────────────────── ② 分拣层 Scope & Aggregate ─────────────────────┐
 │  粒度：字段级 → 记录级 → 表/数据集级 → 跨资产(血缘/聚合)             │
 │  算子：就高从严 = max(子级别)                                        │
 │        + 规模修正（行数/人数/精度超阈值 → 升级）                      │
 │        + 汇聚修正（多来源融合 → 按衍生数据重算）                       │
 └────────────────────────────┬────────────────────────────────────────┘
                              ▼  资产级候选级别 + 依据
 ┌──────────────────── ③ 映射层 Map to Framework ──────────────────────┐
 │  企业内部级别 (L1..Ln)  ↔  国标级别 (核心/重要/一般[1..4])            │
 │  行业口径叠加：能源(三档) / 金融 JR/T 0197(五级) / 金融信息服务(四级) │
 │  输出：可上报的重要数据目录 + 分类分级清单 + 变更 diff                │
 └─────────────────────────────────────────────────────────────────────┘
```

**关键设计判断（写下来避免返工）**：

1. **不存原值**：识别层只落**证据**（规则命中数、采样哈希），不落敏感原文 —— 否则你自己的产品就成了新的泄露面（[网数条例 第10条](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)的 24 小时报告义务也会跟着你）。
2. **正则只是起点**：身份证/银行卡必须做**校验位验证**（GB 11643 的 MOD 11-2、Luhn），否则误报率会高到无法交付。
3. **区分"识别"与"定级"**：识别层回答"这里有什么"，分拣层回答"影响多大"。合成一步会让阈值调不动。
4. **重要数据"目录优先"**：[跨境规定 第2条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm)已明确"未被相关部门告知或公开发布为重要数据的，不需要作为重要数据申报评估"。所以引擎应有**两条路径**：`本地推断(附录G)` 与 `目录比对(行业/地区目录)`，并标记结论来源。

### 3.3 规则的可执行表示

规则建议存成**声明式 JSON**（可热更新、可审计、可版本回滚），而不是硬编码分支：

```json
{
  "rule_id": "gbt43697.appG.g.cii-config",
  "framework": "GB/T 43697-2024",
  "clause": "附录G g)",
  "severity_hint": "重要数据",
  "when": {
    "all": [
      { "fact": "column.semantic_tags", "op": "any_of",
        "value": ["system_config", "topology", "emergency_plan", "audit_log", "asset_inventory"] },
      { "fact": "asset.industry_code", "op": "in", "value": ["telecom", "energy", "finance"] }
    ]
  },
  "score": { "base": 0.70, "boost": [{ "fact": "asset.is_cii_likely", "op": "eq", "value": true, "delta": 0.25 }] },
  "then": {
    "level": "重要数据",
    "evidence_template": "命中 GB/T 43697 附录G g)：CII 系统配置/拓扑/审计日志类数据",
    "requires_review": true
  }
}
```

对应的**置信度与复核模型**：

```
confidence(asset) = 1 - Π(1 - score_i)          # 多规则独立命中取并集
if confidence >= 0.85: 自动定级            (auto)
elif confidence >= 0.60: 入人工复核队列     (review)
else: 维持"待识别"状态并降低采样频率        (unknown)
```

并且必须**记录规则版本与判定时间**，因为附录 J 要求动态更新——评审时需要回答"这条级别是什么时候、按哪版规则判的"。

### 3.4 元数据落库：建议的表结构（PostgreSQL DDL）

```sql
-- 0) 数据源
CREATE TABLE datasource (
  id            BIGSERIAL PRIMARY KEY,
  tenant_id     BIGINT NOT NULL,
  name          TEXT NOT NULL,
  kind          TEXT NOT NULL,          -- 'postgres' | 'mysql' | 's3' | 'kafka' | 'api'
  dsn_ref       TEXT NOT NULL,          -- 只存密钥引用，不存明文凭据
  industry_code TEXT,                   -- 行业领域（GB/T 43697 5.1 a）
  is_cii_likely BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (tenant_id, name)
);

-- 1) 数据资产（表/视图/文件/主题/接口字段）
CREATE TABLE data_asset (
  id            BIGSERIAL PRIMARY KEY,
  tenant_id     BIGINT NOT NULL,
  datasource_id BIGINT NOT NULL REFERENCES datasource(id) ON DELETE CASCADE,
  asset_type    TEXT NOT NULL,          -- 'table'|'view'|'file'|'topic'|'api_field'
  physical_ref  TEXT NOT NULL,          -- schema.table / bucket/key / api path
  display_name  TEXT,
  owner         TEXT,
  row_count     BIGINT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (datasource_id, asset_type, physical_ref)
);

-- 2) 字段级元数据
CREATE TABLE asset_column (
  id           BIGSERIAL PRIMARY KEY,
  asset_id     BIGINT NOT NULL REFERENCES data_asset(id) ON DELETE CASCADE,
  column_name  TEXT NOT NULL,
  ordinal      INT,
  data_type    TEXT,
  comment      TEXT,                    -- 业务注释：语义识别的主要输入
  is_nullable  BOOLEAN,
  sample_hash  TEXT,                    -- 采样指纹（如 salted hash 前缀），不存原值
  distinct_cnt BIGINT,
  null_ratio   NUMERIC(5,4),
  UNIQUE (asset_id, column_name)
);

-- 3) 识别规则（可版本化）
CREATE TABLE classifier_rule (
  id            BIGSERIAL PRIMARY KEY,
  rule_key      TEXT NOT NULL,          -- 'cn.idcard' | 'pii.phone' | 'gbt43697.appB.finance_account'
  detector_type TEXT NOT NULL,          -- 'regex'|'checksum'|'ner'|'dict'|'stat'
  category      TEXT NOT NULL,          -- GB/T 43697 附录B 一级/二级类别 或自定义
  pattern       TEXT,
  validator     TEXT,                   -- 'gb11643_mod11_2' | 'luhn' | NULL
  base_score    NUMERIC(4,3) NOT NULL DEFAULT 0.500,
  framework     TEXT,                   -- 'GB/T 43697-2024'
  clause        TEXT,                   -- '附录B' 等，便于审计溯源
  version       INT  NOT NULL DEFAULT 1,
  enabled       BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (rule_key, version)
);

-- 4) 证据（识别层输出，可回溯）
CREATE TABLE detection_evidence (
  id           BIGSERIAL PRIMARY KEY,
  column_id    BIGINT REFERENCES asset_column(id) ON DELETE CASCADE,
  asset_id     BIGINT REFERENCES data_asset(id) ON DELETE CASCADE,
  rule_id      BIGINT NOT NULL REFERENCES classifier_rule(id),
  hit_count    BIGINT NOT NULL DEFAULT 0,
  sampled_rows BIGINT NOT NULL DEFAULT 0,
  score        NUMERIC(4,3) NOT NULL,
  detected_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON detection_evidence (asset_id, detected_at);

-- 5) 分级结果（当前值 + 历史）
CREATE TABLE classification_result (
  id            BIGSERIAL PRIMARY KEY,
  tenant_id     BIGINT NOT NULL,
  asset_id      BIGINT REFERENCES data_asset(id) ON DELETE CASCADE,
  column_id     BIGINT REFERENCES asset_column(id) ON DELETE CASCADE,
  scope         TEXT NOT NULL,          -- 'column'|'record'|'asset'|'derived'
  gb_level      TEXT NOT NULL,          -- '核心数据'|'重要数据'|'一般数据'
  gb_sub_level  SMALLINT,               -- 一般数据 1..4（附录H）
  internal_level SMALLINT,              -- 企业内部 1..N
  confidence    NUMERIC(4,3) NOT NULL,
  decision      TEXT NOT NULL,          -- 'auto'|'manual'|'override'
  rule_version  TEXT,
  impact_objects TEXT[],                -- {'经济运行','个人权益'}
  impact_degree  TEXT,                  -- '特别严重危害'|'严重危害'|'一般危害'
  reasons       JSONB,                  -- 命中的 clause + 证据快照
  valid_from    TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_to      TIMESTAMPTZ             -- NULL = 当前有效（SCD2）
);
CREATE INDEX ON classification_result (asset_id, valid_to);

-- 6) 企业级别 ↔ 国标/行业级别 映射
CREATE TABLE level_mapping (
  id             BIGSERIAL PRIMARY KEY,
  tenant_id      BIGINT,
  framework      TEXT NOT NULL,         -- 'GB/T 43697-2024' | 'JR/T 0197-2020' | 'NEA-2026'
  internal_level SMALLINT NOT NULL,
  mapped_level   TEXT NOT NULL,
  note           TEXT
);

-- 7) 人工复核队列
CREATE TABLE review_task (
  id           BIGSERIAL PRIMARY KEY,
  asset_id     BIGINT REFERENCES data_asset(id),
  column_id    BIGINT REFERENCES asset_column(id),
  status       TEXT NOT NULL DEFAULT 'open',   -- open|accepted|rejected|edited
  priority     SMALLINT NOT NULL DEFAULT 3,
  suggestion   JSONB,                    -- 引擎建议（级别 + 证据）
  assignee     TEXT,
  decided_at   TIMESTAMPTZ,
  decided_by   TEXT,
  decision_note TEXT
);

-- 8) 对外提供/出境/委托处理台账（对应 3 年留存义务）
CREATE TABLE data_transfer_log (
  id             BIGSERIAL PRIMARY KEY,
  tenant_id      BIGINT NOT NULL,
  asset_id       BIGINT REFERENCES data_asset(id),
  direction      TEXT NOT NULL,          -- 'outbound_cross_border'|'third_party'|'entrusted'
  recipient      TEXT NOT NULL,
  recipient_region TEXT,                 -- '境外-新加坡' 等，用于跨境阈值计量
  contains_personal BOOLEAN NOT NULL DEFAULT FALSE,
  contains_sensitive BOOLEAN NOT NULL DEFAULT FALSE,
  contains_key_data  BOOLEAN NOT NULL DEFAULT FALSE,
  subject_count  BIGINT,                 -- 该次涉及个人信息主体数（用于累计阈值）
  legal_basis    TEXT,                   -- 'security_assessment'|'standard_contract'|'certification'|'exempt'
  occurred_at    TIMESTAMPTZ NOT NULL,
  retention_until TIMESTAMPTZ NOT NULL   -- 默认 occurred_at + 3 年
);
```

**跨境阈值计量**可以直接做成一个视图（对应[跨境规定 第5/7/8条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm)）：

```sql
-- 当年累计出境个人信息主体数（按法条口径拆分"含/不含敏感"）
CREATE VIEW v_cross_border_ytd AS
SELECT tenant_id,
       date_trunc('year', occurred_at) AS y,
       SUM(subject_count) FILTER (WHERE NOT contains_sensitive) AS cnt_normal,
       SUM(subject_count) FILTER (WHERE contains_sensitive)     AS cnt_sensitive,
       BOOL_OR(contains_key_data)                              AS has_key_data
FROM data_transfer_log
WHERE direction = 'outbound_cross_border'
GROUP BY tenant_id, 1;
```

### 3.5 难在哪里（不要低估，也不要被吓退）

1. **没有统一口径，且"一般的口径"本身就是分层的**。国标只给三级（核心/重要/一般）＋一般数据可再分 1–4 级；行业细则各不相同：
   - 能源：**一般/重要/核心三档**，并明确"就高从严""脱敏后无法还原可**降级**""衍生数据能还原则按原级别"（[国家能源局《能源行业数据分类分级指南（2026年版）》，2026-07-01 施行](https://www.nea.gov.cn/20260630/3b456b6f83144abcb989110dcfba4d7d/c.html)）。
   - 金融行业：**JR/T 0197-2020 的五级**（[平台页](https://std.samr.gov.cn/hb/search/stdHBDetailed?id=B081D125A6762DB8E05397BE0A0A5EA7)）。
   - 金融信息服务：六部门《金融信息服务数据分类分级指南》参照 GB/T 43697，将数据**从高到低分为四级：核心数据、重要数据、敏感一般数据、常规一般数据**，分类采用一级 3 类 / 二级 9 类 / 三级 67 类（[网信办答记者问，2026-06-13](https://www.cac.gov.cn/2026-06/13/c_1783104511414074.htm)）。
   → 结论：**映射层必须是数据，不是代码**（`level_mapping` 表 + 行业包插件化），否则每接一个新行业就要改引擎。
2. **敏感度是上下文相关的，不是字段属性**。
   - 同一个手机号字段：在"客户联系表"里是个人信息；**按区域+规模聚合后**可能触发 GB/T 43697 的"区域/群体/覆盖度"要素而升级（就高从严、点面结合）；
   - 同一批坐标：**精度优于 100 米**就从普通数据变成重要数据（附录 G b），这是**精度阈值**而非内容特征；
   - 单条无害、**1000 万条**就是另一回事（附录 H 的规模修正、网数条例第 28 条的 1000 万人门槛）。
   → 结论：分级必须**支持"资产集合"级别的重算**，不能只做字段级打标。
3. **标注数据稀缺、评测无标准答案**。国标没有给出 benchmark；行业细则给的"最低参考级别"是少数可用的硬约束。实践上只能做**抽样人工金标准 + 回归集**（见 §3.6）。
4. **动态性**。附录 J 列了 9 类触发；网数条例第 33 条要求**每年度**风险评估。→ 引擎需要"重算调度 + 变更 diff + 审批"，而不是一次性扫描。
5. **证据链与可解释性**。客户要拿去给监管看；"模型说它是重要数据"不可接受。→ 每条结论必须能回放到 `clause + hit_count + rule_version`。

### 3.6 评测指标（自己先定义，否则无法优化）

| 指标 | 定义 | 用途 |
|---|---|---|
| 字段级 Recall（按类别） | 金标准中该类字段被识别的比例 | 防止漏识（漏识=合规风险，优先级最高） |
| 字段级 Precision（按类别） | 识别为该类的字段中正确比例 | 防止复核成本爆炸 |
| **级别一致率** | 引擎定级 = 专家定级（允许 ±1 子级） | 分级（而非识别）的交付验收线 |
| 复核率 | 落入 `review` 队列的比例 | 人力成本上限；应随反馈闭环下降 |
| 关键类硬约束命中率 | 附录 H 最低参考级别是否被违反（如敏感个信 < 4 级） | **绝对不允许违反**，是 bug 不是指标 |
| 变更漏报率 | 附录 J 触发的重算中，人工发现但引擎未报的比例 | 动态更新能力 |

**推荐的最小评测集构成**：每类 50–200 个字段，覆盖「真敏感/易误报/易漏识（如列名无害但内容是身份证）」三类；每次改规则跑回归。

---

## 4. 技术栈与开源工具

> **阅读约定**：表格里的「许可证」已逐项从各仓库 `LICENSE` 正文或仓库元数据核实（2026-10-13），**改证/已归档的坑已在备注标出**；
> 「实用度」是**工程判断**（面向"单人、10–15h/周、要能支撑 MVP"），不是事实声明。

### 4.1 数据库审计与 SQL 审计

**为什么必须做**：日志留存是硬性法条——[网络安全法 第23条(三)](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)要求网络日志**≥6 个月**；[个人信息保护法 第56条](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html)与[网络数据安全管理条例 第12条](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)要求处理情况记录**≥3 年**。数据库审计日志是这两条最直接的证据来源。

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| pgAudit | [pgaudit/pgaudit](https://github.com/pgaudit/pgaudit) | `PostgreSQL` | 2026-09 | PostgreSQL **语句级**审计扩展（DDL/DML/角色） | **高**：装扩展即用，零额外服务；PG 环境的事实标准 |
| MariaDB Audit Plugin | [MariaDB/server](https://github.com/MariaDB/server)（`plugin/server_audit`） | `GPL-2.0` | 2026-10 | MariaDB（亦可被 MySQL/Percona 复用）审计插件 | 中：配置细，但绑定数据库运维 |
| Percona Audit Log Plugin | [percona/percona-server](https://github.com/percona/percona-server)（`plugin/audit_log`） | `GPL-2.0` | 2026-10 | Percona Server/MySQL 审计日志插件 | 中：等于"换数据库"，非独立组件 |
| Archery | [hhyo/Archery](https://github.com/hhyo/Archery) | `Apache-2.0` | 2026-09 | 多库 SQL 审核/查询平台（含脱敏、工单、审计） | **高**：许可友好、中文文档好、单机 Docker 可起 → 最快搭出"SQL 审计门户" |
| SQLE | [actiontech/sqle](https://github.com/actiontech/sqle) | `MPL-2.0` | 2026-09 | 多库 SQL 全生命周期质量/审核 | 中：活跃但体量重 |
| Yearning | [cookieY/Yearning](https://github.com/cookieY/Yearning) | `AGPL-3.0` | 2026-08 | MySQL SQL 审核/工单 | 中：**AGPL** 商用需谨慎 |
| Bytebase | [bytebase/bytebase](https://github.com/bytebase/bytebase) | 部分开源（`enterprise/` 为商业许可） | 2026-10 | 数据库变更与访问治理（含脱敏、访问控制） | 中：开源边界需先核对 |
| goInception | [hanchuanchuan/goInception](https://github.com/hanchuanchuan/goInception) | `GPL-3.0` | **2024-11（近停滞）** | MySQL SQL 审核/执行/回滚 | 低：不建议用于新项目 |

**工程要点**：
1. **两个时长要分开实现**：网络/安全日志 180 天，与"处理情况记录"3 年，是**两套保留策略、两套存储**，别混在一张表里。
2. **完整性才算合规**：日志能改等于没有。落地方式是**哈希链/追加写 + 定期校验点**（见 §5 项目 D）。
3. **成本控制**：语句级审计的存储量极大，建议"热 90 天全量 + 冷归档哈希化"。

### 4.2 API 安全

**为什么必须做**：数据资产的暴露面已经从"数据库"迁移到"API"。OWASP 官方现行清单为 **API Security Top 10:2023**（[官方清单页](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)），其中 **API1（对象级授权失效）、API3（对象属性级授权失效）、API5（功能级授权失效）** 三项全部是**授权粒度**问题——本质就是"谁能按什么用途取哪一级数据"，与数据分类分级天然同构。[网络数据安全管理条例 第16条](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)还额外禁止服务商对委托方数据做**关联分析**，这属于 API 层的租户隔离要求。

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| Apache APISIX | [apache/apisix](https://github.com/apache/apisix) | `Apache-2.0` | 3.19.0（2026-09） | 云原生 API 网关：JWT/OIDC、RBAC、IP 黑白名单、WAF、mTLS | **高**：ASF 顶级项目、插件最全、单机 Docker 易起 |
| Kong Gateway (OSS) | [Kong/kong](https://github.com/Kong/kong) | `Apache-2.0` | 2026-10 | API/AI 网关：认证插件、限流、mTLS、Secret 管理 | **高**：极活跃、插件生态成熟 |
| OWASP ZAP | [zaproxy/zaproxy](https://github.com/zaproxy/zaproxy) | `Apache-2.0` | 2026-10 | DAST 扫描，支持导入 OpenAPI | **高**：CI 可 Docker 一键跑，直接支撑"API 安全检查"教学内容 |
| KrakenD CE | [krakend/krakend-ce](https://github.com/krakend/krakend-ce) | `Apache-2.0` | 2026-10 | 声明式无状态网关（JWT/限流） | 中：安全功能较基础 |
| Tyk Gateway | [TykTechnologies/tyk](https://github.com/TykTechnologies/tyk) | `MPL-2.0`（`ee/` 为商业许可） | 2026-10 | 网关（认证/配额/限流/分析） | 中：注意 `ee/` 边界 |
| APIClarity | [openclarity/apiclarity](https://github.com/openclarity/apiclarity) | `Apache-2.0` | **已归档**（最后提交 2024-10） | 流量重建 OpenAPI、识别 shadow/zombie API | 低：**停止维护**，不建议新采用 |

> **由此产生的产品缺口（可做）**：APIClarity 归档后，**影子 API 发现**在开源侧基本没有现成件。用"网关访问日志（实际端点集合）− OpenAPI 文档（声明端点集合）"的**集合差**自己实现，两天可出 MVP（见 §5 项目 E）。

### 4.3 敏感数据识别 / DSPM / 元数据 / DLP

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| Microsoft Presidio | [data-privacy-stack/presidio](https://github.com/data-privacy-stack/presidio)（原 `microsoft/presidio` 已重定向） | `MIT` | 2026-10 | PII 识别/脱敏框架（NLP + 正则 + 可插拔识别器） | **高**：`pip install` 即用；**但内置以英文为主，中文识别器要自己写**，这正是差异化空间 |
| OpenMetadata | [open-metadata/OpenMetadata](https://github.com/open-metadata/OpenMetadata) | `Apache-2.0` | 2026-10 | 元数据/数据目录（含分级、血缘、质量） | **高**：单机 Docker 可起，OSS 元数据/分级最现实选择 |
| DataHub | [datahub-project/datahub](https://github.com/datahub-project/datahub) | `Apache-2.0` | 2026-10 | 数据目录/血缘/分类/访问治理 | 中：生态强但偏团队级投入 |
| Apache Atlas | [apache/atlas](https://github.com/apache/atlas) | `Apache-2.0` | 2026-10 | 元数据/血缘/分类分级（Hadoop 生态） | 中：依赖重（HBase/Kafka/Solr） |
| Amundsen | [amundsen-io/amundsen](https://github.com/amundsen-io/amundsen) | `Apache-2.0` | **已归档** | 元数据发现 | 低：不建议新采用 |
| openDLP（哈工大深圳 IDS） | [hitsz-ids/openDLP](https://github.com/hitsz-ids/openDLP) | `Apache-2.0` | 2026 | 中文敏感数据识别/分类分级 | 中：中文场景值得单独评估（注意与下面**已废弃**的同名英文项目无关） |
| OpenDLP（ezarko，历史项目） | [ezarko/opendlp](https://github.com/ezarko/opendlp) | `GPL-3.0` | **2014（事实废弃）** | 终端 DLP 扫描 | 低：仅作历史参考 |
| gitleaks | [gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) | `MIT` | 2026-09 | 代码/历史中的密钥泄露检测 | **高**：单二进制 + pre-commit，落地成本几乎为零 |
| TruffleHog | [trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) | **`AGPL-3.0`**（v3 起改证，旧版 MIT） | 2026-10 | 密钥扫描 + **在线验证凭证有效性** | 高（能力）/ 谨慎（许可）：AGPL 对闭源集成有约束 |
| detect-secrets | [Yelp/detect-secrets](https://github.com/Yelp/detect-secrets) | `Apache-2.0` | 2026-04 | 带基线与审计流程的密钥检测 | 中：适合 CI 增量检测 |

**现实结论（避免踩空）**：**开源界没有可直接交付的"DLP 产品"**。可走的路是拼装：
`Presidio/openDLP（识别）` + `§3 分级引擎（定级）` + `OPA/OpenFGA（策略）` + `网关/数据库代理（拦截）` + `Wazuh（告警）`。
"识别 + 分级"是其中最可复用、最可产品化的那一环。

### 4.4 脱敏 / Tokenization / 合成数据

**方法论依据**：[GB/T 37964-2019 信息安全技术 个人信息去标识化指南](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=C8DF1BC2FB43C6EC0E602EB65EF0BC66)（发布 2019-08-30，实施 2020-03-01，**现行**）给出脱敏目标、技术、模型与过程；[GB/T 43697-2024 附录I](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F0C385EDC38CBF277AEC021F23126ADE)则规定**脱敏数据级别可比原始数据降低**——所以"脱敏"在合规上是**可验证的降级算子**，不是"打码截图"。

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| postgresql_anonymizer | [dalibo/postgresql_anonymizer](https://gitlab.com/dalibo/postgresql_anonymizer)（**官方在 GitLab**，GitHub 已无） | `PostgreSQL` | 2026-10 | PG 动态掩码 + 静态匿名化扩展 | **高**：库内脱敏最省事，支持"同一假名可关联"的伪匿名 |
| ARX Data Anonymization Tool | [arx-deidentifier/arx](https://github.com/arx-deidentifier/arx) | `Apache-2.0` | 2025-10 | k-匿名 / l-多样性 / 差分隐私 | 中：离线批量强，流水线集成需额外工作 |
| Faker | [joke2k/faker](https://github.com/joke2k/faker) | `MIT` | 2026-10 | 假数据生成 | 高（但注意）：生成的是**随机假数据，不保留统计分布**，只适合演示/填充 |
| SDV | [sdv-dev/SDV](https://github.com/sdv-dev/SDV) | **`BUSL-1.1`（非开源，4 年后转 MIT）** | 2026-10 | 表格/多表/时序**合成数据**（保留分布） | 中：质量高，但商用须先评估许可 |
| OpenToken | [TruvetaPublic/OpenLinkToken](https://github.com/TruvetaPublic/OpenLinkToken)（`Truata/opentoken` **已 404**） | `MIT` | 2026-10 | 基于哈希的隐私保护记录匹配/令牌化 | 低：项目小、生态弱，仅作备选 |

**Tokenization 的现实**：开源界缺乏成熟的企业级 vaulted tokenization（格式保持加密 + 令牌保险库）。若要做，**自建令牌保险库**（`token ↔ 密文值`，密钥放 KMS，见 §4.6）比找现成件更快，也更贴合[密码法 第26/27条](http://www.npc.gov.cn/npc/c1773/c1848/c21114/c36794/c36798/201910/t20191028_301735.html)的国密要求。

### 4.5 权限最小化与 IBAC（意图/属性驱动的授权）

**为什么必须做**：分类分级的价值**只有在授权层被消费时才成立**——分完级却仍全库可读，等于没分。[个人信息保护法 第51条(四)](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html)明确要求"**合理确定处理的操作权限**"。

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| Open Policy Agent (OPA) | [open-policy-agent/opa](https://github.com/open-policy-agent/opa) | `Apache-2.0` | v1.21.2（2026-10） | 通用策略引擎（Rego），"策略即代码" | **高**：生态最广，ABAC 事实标准 |
| Cedar | [cedar-policy/cedar](https://github.com/cedar-policy/cedar) | `Apache-2.0` | 2026-10 | 授权策略语言/引擎（AWS 开源，Rust） | 中：表达力好，生态小于 OPA |
| OpenFGA | [openfga/openfga](https://github.com/openfga/openfga) | `Apache-2.0` | v1.22.0（2026-10） | 细粒度授权（Zanzibar 模型 / ReBAC） | **高**：CNCF 项目、单容器可起，ReBAC 首选 |
| SpiceDB | [authzed/spicedb](https://github.com/authzed/spicedb) | `Apache-2.0` | 2026-10 | Zanzibar 风格授权数据库 | 中：性能强，但需独立运维 |
| Casbin | [apache/casbin](https://github.com/apache/casbin)（原 `casbin/casbin` 已重定向） | `Apache-2.0` | 2026-10 | 多语言访问控制**库**（ACL/RBAC/ABAC） | **高**：已入 Apache 基金会；库形态零部署 |
| Permify | [Permify/permify](https://github.com/Permify/permify) | `AGPL-3.0` | 2026-10 | 授权即服务 | 低/中：已被收购，路线不确定 |

**IBAC 要说清楚**：术语起点是 insider-threat 研究——Almehmadi & El-Khatib, *On the Possibility of Insider Threat Prevention Using Intent-Based Access Control (IBAC)*, IEEE Systems Journal（[IEEE Xplore 7103286](https://ieeexplore.ieee.org/document/7103286)），其思路是用**行为/生理信号推断访问意图**，参与授权决策；近年被重新用于 **AI Agent 授权**（把"用户委托的意图"作为策略输入）。
**实践口径**：不必等"IBAC"标准化——把**数据级别 + 访问用途(purpose) + 风险信号**作为属性喂给 **OPA/Cedar**，即可得到 90% 的等价效果：

```rego
# 示例：分级驱动的授权（OPA/Rego 风格）
allow if {
  input.action == "read"
  data.classification[input.asset_id].gb_level == "一般数据"
  data.classification[input.asset_id].gb_sub_level <= user_clearance(input.subject)
  purpose_ok(input.purpose, data.classification[input.asset_id])
}
# 重要数据/核心数据：默认 deny，需显式审批 + 用途白名单 + 记录审计
allow if {
  input.approval_id != ""
  data.classification[input.asset_id].gb_level in {"重要数据", "核心数据"}
  input.purpose in data.approved_purposes[input.asset_id]
}
default allow := false
```

### 4.6 KMS 与密钥托管

**合规约束**：[密码法 第27条](http://www.npc.gov.cn/npc/c1773/c1848/c21114/c36794/c36798/201910/t20191028_301735.html)要求相关 CII 运营者使用商用密码并开展**商用密码应用安全性评估（密评）**；[第26条](http://www.npc.gov.cn/npc/c1773/c1848/c21114/c36794/c36798/201910/t20191028_301735.html)要求列入目录的商用密码产品**检测认证合格方可销售**。→ 面向国内政企的加密/KMS 产品，**国密算法（SM2/SM3/SM4）与密评材料导出**是硬需求。

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| OpenBao | [openbao/openbao](https://github.com/openbao/openbao) | `MPL-2.0` | v2.7.1（2026-10） | Vault 的 Linux 基金会 OSS 分支（API 兼容） | **高**：要 Vault 能力又不想碰 BUSL 时的首选 |
| HashiCorp Vault | [hashicorp/vault](https://github.com/hashicorp/vault) | **`BUSL-1.1`（v1.15.0 起改证，非开源）** | v2.2.0-rc1（2026-10） | 机密管理 / 加密即服务 / 特权访问 | 中：能力最强，但 BUSL 限制"竞争性"用途，商用须评估 |
| Mozilla SOPS | [getsops/sops](https://github.com/getsops/sops) | `MPL-2.0` | 2026-10 | 加密 YAML/JSON/ENV，Git 内安全存机密 | **高**：单二进制，GitOps 最实用 |
| Bitnami sealed-secrets | [bitnami-labs/sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) | `Apache-2.0` | 2026-10 | K8s 单向加密 Secret | **高**：K8s 场景即装即用（无 K8s 不适用） |
| age | [FiloSottile/age](https://github.com/FiloSottile/age) | `BSD-3-Clause` | 2026-08 | 现代文件加密（含 Go 库） | **高**：零配置、单二进制 |
| Google Tink | [tink-crypto/tink](https://github.com/tink-crypto/tink)（按语言实现，如 [tink-go](https://github.com/tink-crypto/tink-go)） | `Apache-2.0` | tink-go 2026-10（总仓库 2024-04） | 跨语言密码学 API 库（"难被误用"） | 中：库而非服务，零部署 |
| PyKMIP | [OpenKMIP/PyKMIP](https://github.com/OpenKMIP/PyKMIP) | `Apache-2.0` | 2026-09 | KMIP 协议的 Python 实现 | 中：适合 KMS 对接与实验 |

**三个易错点**：
1. **Vault ≠ 开源**（BUSL-1.1，2023 年 8 月随 1.15.0 改证）——产品里内嵌前必须过法务。
2. **密钥托管 ≠ 加密**：合规上要能证明"密钥与数据分离、有访问审计、可轮转、可销毁"。
3. **国密**：SM 系列不是可选项而是准入条件（尤其 CII/政务客户）。

### 4.7 数据泄露检测与取证

**为什么必须做**：[网络数据安全管理条例 第10条](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)要求涉危害国家安全、公共利益的漏洞/缺陷在 **24 小时内报告**；[网络安全法 第24/27条](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)要求漏洞立即补救并按规定报告；[个人信息保护法 第57条](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html)要求泄露时立即补救并通知。→ 没有**检测与取证能力**，"按时报告"就无从谈起。

| 工具 | 官方仓库 | 许可证 | 活跃度 | 定位 | 实用度 |
|---|---|---|---|---|---|
| Wazuh | [wazuh/wazuh](https://github.com/wazuh/wazuh) | `GPL-2.0` | 2026-10 | 开源 XDR/SIEM（HIDS、日志分析、FIM、合规） | **高**：单体可起，主机/日志侧"全家桶" |
| Zeek | [zeek/zeek](https://github.com/zeek/zeek) | `BSD-3-Clause` | 2026-10 | 网络分析框架（流量记录 + 脚本化检测） | **高**：网络可见性与取证基础 |
| Suricata | [OISF/suricata](https://github.com/OISF/suricata) | `GPL-2.0` | 2026-10 | IDS/IPS/NSM 引擎 | 高：与 Zeek 常配套 |
| Sigma | [SigmaHQ/sigma](https://github.com/SigmaHQ/sigma) | `DRL-1.1`（规则许可） | 2026-10 | 通用日志检测规则格式与规则库 | **高**：检测规则的公共语言；DRL 对商用**再分发**有约束 |
| Velociraptor | [Velocidex/velociraptor](https://github.com/Velocidex/velociraptor) | `AGPL-3.0` | 2026-10 | 端点实时取证与威胁狩猎（VQL） | 高（能力）/ 谨慎（AGPL） |
| GRR | [google/grr](https://github.com/google/grr) | `Apache-2.0` | 2026-10 | 远程实时取证/响应框架 | 中：架构重，适合规模化 IR |
| Timesketch | [google/timesketch](https://github.com/google/timesketch) | `Apache-2.0` | 2026-10 | 协作式时间线分析（需 OpenSearch） | 中/高 |
| Plaso | [log2timeline/plaso](https://github.com/log2timeline/plaso) | `Apache-2.0` | 2026-10 | Super timeline 生成 | 中：与 Timesketch 配套 |
| Chainsaw | [WithSecureOpenSource/chainsaw](https://github.com/WithSecureOpenSource/chainsaw) | `Apache-2.0` | 2026-09 | Windows 取证产物快速搜索（Sigma 驱动） | 中/高：单二进制 |
| Hayabusa | [Yamato-Security/hayabusa](https://github.com/Yamato-Security/hayabusa) | `AGPL-3.0` | 2026-10 | Sigma 驱动的 Windows 日志狩猎/时间线 | 中/高 |
| TheHive | [TheHive-Project/TheHive](https://github.com/TheHive-Project/TheHive) | `AGPL-3.0` | **开源版停更（2025-07），转商业发行** | 协作式事件/案件管理 | 低：不建议新采用 |
| Volatility 3 | [volatilityfoundation/volatility3](https://github.com/volatilityfoundation/volatility3) | 自定义 `Volatility Software License 1.0`（**无标准 SPDX**） | 2026-10 | 内存取证 | 中：事实标准；自定义许可偏 copyleft，商用前读条款 |

> **与"数据资产安全"的接合点**：通用 SIEM/IDS 不知道"什么数据算敏感"，所以**同一条外传流量，传的是公开数据还是核心数据，风险完全不同**。把 §3 的分级结果作为**检测上下文**注入（如"核心数据表名出现在 SQL 里"→ 高级别告警），是这个方向相对传统安全产品**真正的差异化**。

### 4.8 单人 MVP 的最小组合（结论）

| 能力 | 选择 | 理由 |
|---|---|---|
| 敏感识别 | Presidio + **自写中文识别器** | MIT、pip 即用；中文是差异化 |
| 分级与台账 | **自研**（§3 schema） | 开源无现成件，且这是核心资产 |
| 脱敏 | postgresql_anonymizer（库内）/ 自建令牌保险库 | 许可宽松、贴合附录 I 降级逻辑 |
| 授权 | OPA 或 Casbin（嵌入式） | 零/低部署成本 |
| 密钥 | SOPS + age（GitOps）；集中式则 OpenBao | 避免 BUSL |
| 审计日志 | pgAudit（PG）/ Archery（要门户） | 直接对应法条留存期限 |
| 检测 | Wazuh | 单体全覆盖 |
| 网关 | Apache APISIX | API 侧统一入口 |

---

## 5. 可快速落地的项目候选（按 1–3 天出 MVP 排序）

排序原则：**越靠前越依赖少、越靠前越能当"教学内容的第一课"**。每个项目都刻意选择"能同时产出产品与课程"的形态。

### 项目 A · 中文敏感数据发现器（1 天）

- **最小依赖**：Python 3.11+；`presidio-analyzer`；一个 CSV/SQLite 文件。无服务、无 DB。
- **输入**：CSV/JSON 文件（或 SQLite 表）+ 列名。
- **输出**：`findings.json` —— 每列一条：`{table, column, category(GB/T 43697 附录B 类别), detector, hit_count, sample_size, confidence, suggested_level}`。
- **必须自己写的部分**（也是护城河）：3 个中文识别器——**身份证（GB 11643 MOD 11-2 校验位）**、手机号（号段正则 + 长度）、银行卡（**Luhn** 校验）。做校验位是 precision 的分水岭。
- **验收标准**：
  1. 在 20 张合成表（每类至少 2 列，含 3 列"列名无害但内容是敏感数据"的陷阱列）上，身份证/手机号 **recall ≥ 0.95**；
  2. 误报（普通数字列被判为银行卡）**≤ 5%**；
  3. 每一条 finding 都能映射到 GB/T 43697 附录 B 的一级/二级类别（[标准页](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=F0C385EDC38CBF277AEC021F23126ADE)）。
- **教学化**：拆成两节课——① "正则 + 校验位：为什么身份证不能只用正则"；② "误报分析：precision/recall 与阈值怎么调"。学员能带着自己的数据跑。

### 项目 B · 分类分级引擎 + 元数据台账（2 天）★ 建议作为主线

- **最小依赖**：PostgreSQL 或 SQLite + FastAPI + Alembic；无消息队列、无前端（先用 CLI + SQL 查询）。
- **输入**：项目 A 的 `findings.json` + 表/字段元数据（可用 `information_schema` 抓）。
- **输出**：§3.4 的 `classification_result` 当前值 + SCD2 历史；**重要数据候选清单**（附录 G 规则命中）；级别变更 diff。
- **验收标准**（这几条都是可写成测试的）：
  1. **表 1 全 15 个格子**的单测通过（`(影响对象, 影响程度) → 级别`）；
  2. **就高从严**：多规则冲突时取最高级（含"数据集 = max(数据项) 且规模超阈值则升级"）；
  3. **附录 H 硬约束不被违反**：敏感个人信息 ≥ 4 级、一般个人信息 ≥ 2 级、去标识化个人信息 ≥ 2 级、禁止开放的公共数据 ≥ 4 级；
  4. 任一条结论可通过 `reasons` 字段回放到 `rule_version + clause + hit_count`；
  5. 重跑不产生重复记录（幂等），变更有 `valid_from/valid_to`。
- **教学化**：这是最好的"**把法条翻译成代码**"课程主线——每节课讲一个条款（表 1、附录 G、附录 H、附录 J）→ 现场写规则 → 现场写单测。

### 项目 C · 数据出境台账与阈值告警（2–3 天）

- **最小依赖**：项目 B 的库 + 一个日志解析脚本（Nginx/网关日志或数据库访问审计）。无外部服务。
- **输入**：带"目的地/用途/涉及主体数"的出站访问记录。
- **输出**：当年累计计量视图（`cnt_normal` / `cnt_sensitive` / `has_key_data`）+ **阈值判定结论**（豁免 / 标准合同或认证 / 安全评估）+ 保留至 `occurred_at + 3 年` 的台账。
- **验收标准**：
  1. 用边界样例（9.9 万 / 10 万 / 10 万零 1 / 100 万）跑出的结论与 [跨境规定 第5、7、8条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm)一致；
  2. "重要数据"识别区分**两条来源**：本地推断（附录 G）vs 目录比对，并在结论里标注来源（依据[第2条](https://www.cac.gov.cn/2024-03/22/c_1712776611775634.htm)）；
  3. 台账不可删除（只能追加 + 逻辑作废）。
- **教学化**："法条阈值 → 决策表 → 代码"的经典转换课；可作为合规培训的实操题。

### 项目 D · 6 个月日志留存 + 防篡改审计基线（3 天）

- **最小依赖**：PostgreSQL + `pgaudit` 扩展 + 一个哈希链脚本（或 S3 对象锁）。无 SIEM。
- **输入**：PostgreSQL 审计日志。
- **输出**：可校验的归档存储 + `verify` CLI + 保留策略配置（网络/安全日志 180 天；处理情况记录 3 年）。
- **验收标准**：
  1. 篡改任意一条历史记录后 `verify` 必须失败并定位到该条；
  2. 能回答"**6 个月前的某次查询是谁、从哪、查了什么**"；
  3. 冷归档的存储成本可估算（给出 每百万条/月的字节数）。
- **教学化**："合规留存 vs 成本"、WORM/哈希链原理、审计日志的字段设计。

### 项目 E · API 资产盘点与 BOLA/授权粒度检查（3 天）

- **最小依赖**：OpenAPI spec（YAML）+ 网关访问日志 + （可选）OWASP ZAP。纯脚本可先跑。
- **输入**：声明的端点集合（spec）与实际的端点集合（日志）。
- **输出**：① **影子/僵尸 API 清单**（集合差）；② 对照 **API Security Top 10:2023** 十项的检查表与风险排序（[官方清单](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)）。
- **验收标准**：
  1. 在含 3 个影端点、2 个僵尸版本的样例上**全部识别**；
  2. 检查表 **100% 覆盖 OWASP API Top 10:2023 的 10 项**，其中 API1/API3/API5 的检查项与"数据分级"挂钩；
  3. 每个结论附上可复核的证据（日志行号 / spec 路径）。
- **教学化**：OWASP API Top 10 逐项实操；"影子 API 为什么是数据泄露最常见的入口"。

**优先级建议**：A → B →（C 与 D 并行）→ E。理由是 **B 是所有其他项目的公共依赖**（DLP、出境台账、脱敏、风险报告都要分级结果）。

---

## 6. 知识清单（按依赖顺序分层）

### ① 一小时懂（能开口、能判断别人说得对不对）

- 三法一条例的**层级与关系**：[网络安全法](https://www.cac.gov.cn/2025-12/29/c_1768735112911946.htm)（网络运行安全 + 等保）、[数据安全法](http://www.npc.gov.cn/c2/c30834/202106/t20210610_311888.html)（分类分级 + 重要数据）、[个人信息保护法](http://www.npc.gov.cn/npc/c2/c30834/202108/t20210820_313088.html)（个人信息）、[网络数据安全管理条例](https://www.gov.cn/zhengce/content/202409/content_6977766.htm)（把上面三部落地成可执行义务）。
- **记死三个数字**：日志 **6 个月**、处理情况记录 **3 年**、重要数据风险评估 **每年一次**。
- **记死三个跨境阈值**：10 万人（豁免线）、100 万人 / 1 万敏感（评估线）。
- 分清 **核心数据 / 重要数据 / 一般数据**，以及"一般数据可再分 1–4 级"。
- **知道 2025 年网安法改了**，别再引旧条文号。

### ② 一天能上手（能跑起来、能演示）

- 跑通 Presidio，并**给它加一个自定义中文识别器**（身份证 + 校验位）。
- 通读 GB/T 43697 第 5、6 章（分类规则、分级规则），能背出"8 个分级要素 + 6 类影响对象 + 3 档影响程度"。
- 装 pgaudit 并验证一条语句能被记录。
- 看懂 OWASP API Top 10:2023 的十项，并能对着一张 API 清单指出哪几项适用。
- 用 Docker 起一个 OpenMetadata 或 Archery，理解"元数据台账"长什么样。

### ③ 一周能做工（能交付可验收的模块）

- 把 §3.4 的 schema 建成表，并实现**表 1 查表 + 就高从严 + 数据集 max** 三个算子。
- 实现**附录 H 最低参考级别**的硬约束断言测试。
- 用 OPA/Casbin 写第一条"分级驱动授权"策略，并接到一个真实 API 上。
- 把等保 2.0（[GB/T 22239-2019](https://openstd.samr.gov.cn/bzgk/std/newGbInfo?hcno=BAFB47E8874764186BDB7865E8344DAF)）的控制项做成一份"我们支持哪些、不支持哪些"的映射表。
- 实现日志哈希链 + verify。

### ④ 一个月能交付（客户/团队级交付物）

- 完整分级引擎 + 复核工作流 + 变更 diff + 导入导出（可上报的重要数据目录格式）。
- 依据 [GB/T 45577-2025](https://std.samr.gov.cn/gb/search/gbDetailed?id=33D40F1161195D92E06397BE0A0A5B93) 做**风险评估报告自动化**（对应数安法 30 条 / 网数条例 33 条的年度报送）。
- DSPM 形态：接入 OpenMetadata + 定时扫描 + 风险看板。
- 数据出境台账 + 阈值告警 + 豁免判定。
- 一份可交付的《数据分类分级实施细则》模板（企业自己写不出来，这就是咨询价值）。

### ⑤ 需要长期（护城河，也是别急着承诺的部分）

- **行业口径**：金融（[JR/T 0197-2020 五级](https://std.samr.gov.cn/hb/search/stdHBDetailed?id=B081D125A6762DB8E05397BE0A0A5EA7)）、能源（[三档 + 就高从严 + 脱敏降级](https://www.nea.gov.cn/20260630/3b456b6f83144abcb989110dcfba4d7d/c.html)）、金融信息服务（[四级 + 67 个三级类](https://www.cac.gov.cn/2026-06/13/c_1783104511414074.htm)）、教育、民航……**每接一个行业就要吃透一套细则**。
- **中文 PII 精度**：姓名/地址/机构名/病历的自由文本识别，是所有指标里最难压的。
- **密评与商用密码**：国密改造、密评材料、检测认证路径。
- **监管沟通能力**：重要数据目录申报、数据出境评估材料的实际写法。
- **数据要素流通侧的合规**：数据交易、公共数据授权运营等（与数据安全同源但在另一条线上）。

---

## 附：核实方法、局限与未核实项

**核实方法**：所有法规/标准/开源项目链接均在 **2026-10-13** 现场抓取并逐字比对页面上的日期、文号与版本号；开源项目的**许可证取自仓库 `LICENSE` 正文**（例如 Vault 的 BUSL-1.1、Presidio 的 MIT、SDV 的 BUSL-1.1、Sigma 的 DRL 1.1 均已逐字确认），**仓库位置变更以 HTTP 重定向的最终 URL 为准**（如 `microsoft/presidio` → `data-privacy-stack/presidio`）。GB/T 43697-2024 的条款结构（第 5–7 章、附录 A/B/G/H/I/J）取自标准正文扫描件。

**已知局限**：
1. **标准全文不在开放网页**：`openstd.samr.gov.cn` 与 `tc260.org.cn` 只提供标准的号/名/日期/状态与在线预览入口，**条款级引用无法用 URL 精确定位**；本文对 GB/T 43697-2024 的条款引用以标准正文为准，链接指向其官方标准页。
2. **法规会变**：特别是《网络安全法》刚经历 2025 年修正（2026-01-01 施行），任何写死的条文号都应在交付前重新核对。
3. **本文不构成法律意见**。

**未核实项（明确标注，避免被误当已核实）**：

| 项 | 状态 |
|---|---|
| OWASP API Security Top 10 是否有 2025/2026 新版或更新计划 | `[未核实]`：官方项目页仍标注 2023 为最新发布版 |
| OWASP Top 10:2025 的**精确发布日历日** | `[未核实]`：官方仅给出"2025 年 11 月第一周"的计划表述 |
| OWASP Data Security Top 10 的精确发布日 | `[未核实]`：项目页列 DATA1:2025 … DATA10:2025，未给日历日 |
| NIST Privacy Framework 1.1 正式版发布时间 | `[未核实]`：1.1 目前仍为 Initial Public Draft；1.0 仍为现行正式版 |
| OWASP Top 10 Privacy Risks v2.0 精确发布日期 | `[未核实]`：官方页仅按 2021/2014 两列排名呈现 |
| 各行业数据分类分级细则的完整清单 | 未穷举；本文仅核实到金融、金融信息服务、能源三例 |

