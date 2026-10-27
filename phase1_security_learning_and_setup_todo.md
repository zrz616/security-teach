# 第一阶段（Day 1–30）：Web/API安全检测与外部数字资产测绘 TODO-LIST

本清单对应《网络安全与数字资产安全：学习路径与快速落地项目清单》的**第一阶段（第 1～30 天）**，聚焦于**零资质门槛的外部数字资产暴露面测绘（EASM）**与**Web/API安全检测**能力建设。完成本清单全部事项后，你将拥有一套可运行的本地安全测试靶场、手工抓包分析环境，以及一套输入主域名即可自动输出暴露面风险数据的命令行与 Python 编排原型。

## 1. 基础运行与开发环境搭建（Day 1–3）

外部资产测绘与漏扫核心工具链（ProjectDiscovery 系列）基于 Go 语言构建，自动化编排与报告生成基于 Python 3 构建，建议在 Linux（Ubuntu 22.04/24.04 LTS）、macOS 或 Windows WSL2 环境下统一配置。

- [ ] **准备主力测试与开发操作系统环境**
  - 配置 Ubuntu 22.04/24.04 LTS（虚拟机、云服务器或 Windows WSL2）或 macOS 终端环境。
  - 更新系统基础依赖包并安装常用网络诊断工具（`curl`、`git`、`jq`、`dig`、`nmap`、`tmux`）。
- [ ] **安装并验证 Go 语言环境（支撑核心扫描引擎编译与安装）**
  - 参考 [Go 官方安装文档](https://www.google.com/search?q=https%3A%2F%2Fgo.dev%2Fdoc%2Finstall) 下载并安装最新稳定版 Go（建议 Go 1.21+）。
  - 将 `$HOME/go/bin` 与 `/usr/local/go/bin` 写入 `~/.bashrc` 或 `~/.zshrc` 的 `PATH` 环境变量中：
    ```bash
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    ```
  - 运行 `go version` 验证输出正常。
- [ ] **配置 Python 3 虚拟环境（支撑扫描任务编排与报告生成）**
  - 安装 Python 3.10+ 与 `venv` 模块，创建独立的项目虚拟环境：
    ```bash
    python3 -m venv ~/sec-mvp-env
    source ~/sec-mvp-env/bin/activate
    ```
  - 规划用于解析 JSON 扫描结果的常用标准库与第三方库（如 `subprocess`、`json`、`jinja2`、`fastapi`）。
- [ ] **安装轻量容器引擎 Docker（仅用于一键启动本地合法测试靶场，无需学 K8s）**
  - 安装 Docker Engine 与 Docker Compose，用于秒级拉起本地漏洞练习靶场，避免在未经授权的公网目标上直接测试触碰法律红线。

## 2. 安全检测工具链部署与验证（Day 4–7）

以下工具构成第一阶段“手工渗透分析 + 自动化资产测绘与漏扫”的最小闭环。

| 工具名称 | 核心用途 | 安装与获取参考 | 必做验证动作 |
| :--- | :--- | :--- | :--- |
| **Burp Suite Community Edition** | Web与API流量代理拦截、请求重放（Repeater）、越权与注入手工验证 | [Burp Suite 社区版下载页](https://www.google.com/search?q=https%3A%2F%2Fportswigger.net%2Fburp%2Fcommunitydownload) 及 [Burp Suite 官方安装指南](https://www.google.com/search?q=https%3A%2F%2Fportswigger.net%2Fburp%2Fdocumentation%2Fdesktop%2Fgetting-started%2Fdownload-and-install) | 完成内置浏览器或本地浏览器 CA 证书导入（参考 [Burp CA 证书配置指南](https://www.google.com/search?q=https%3A%2F%2Fportswigger.net%2Fburp%2Fdocumentation%2Fdesktop%2Fexternal-browser-config%2Fcertificate)），成功拦截一条 HTTPS 请求 |
| **Zed Attack Proxy (ZAP)** | 开源 Web 应用被动与主动扫描器、API 接口自动化探测 | [ZAP 官方文档与下载中心](https://www.google.com/search?q=https%3A%2F%2Fwww.zaproxy.org%2Fdocs%2F) | 启动 ZAP Desktop 或命令行模式，加载一个 OpenAPI/Swagger 样例文件测试接口解析 |
| **ProjectDiscovery Subfinder** | 企业外部数字资产被动子域名枚举（不直接接触目标服务器，隐蔽安全） | [Subfinder GitHub 仓库](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fsubfinder) 及 [Subfinder 安装文档](https://www.google.com/search?q=https%3A%2F%2Fdocs.projectdiscovery.io%2Fopensource%2Fsubfinder%2Finstall) | 执行 `go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest`，运行 `subfinder -version` 验证 |
| **ProjectDiscovery httpx** | 存活 Web 资产探测、HTTP 状态码、页面标题、组件指纹与 SSL 证书到期核查 | [httpx GitHub 仓库](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fhttpx) 及 [httpx 安装文档](https://www.google.com/search?q=https%3A%2F%2Fdocs.projectdiscovery.io%2Fopensource%2Fhttpx%2Finstall) | 执行 `go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest`，验证注意与 Python 的 httpx 命令区分路径 |
| **ProjectDiscovery Nuclei** | 基于 YAML 模板的高性能漏洞、弱口令、未授权访问与配置错误扫描器 | [Nuclei GitHub 仓库](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fnuclei) 及 [Nuclei 安装文档](https://www.google.com/search?q=https%3A%2F%2Fdocs.projectdiscovery.io%2Fopensource%2Fnuclei%2Finstall) | 执行 `go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` 并同步拉取官方模板库 |
| **Nuclei Templates** | 社区维护的数千个 CVE、默认口令、敏感信息暴露与指纹检测规则库 | [Nuclei Templates 官方仓库](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fnuclei-templates) | 运行 `nuclei -update-templates`，查看本地 `~/.nuclei/nuclei-templates/` 目录下的 `http/exposures` 与 `http/misconfiguration` 分类 |

- [ ] **完成 ProjectDiscovery 三剑客流水线联调测试**
  - 在终端测试标准管道命令（以官方合法测试域或自有域名为例）：
    ```bash
    subfinder -d example.com -silent | httpx -silent -title -tech-detect -status-code -json -o live_assets.json
    ```
- [ ] **部署本地合法漏洞练习靶场（严禁对未授权公网资产发起主动漏扫）**
  - 基于 [OWASP Juice Shop 项目主页](https://www.google.com/search?q=https%3A%2F%2Fowasp.org%2Fprojects%2Fjuice-shop) 与 [Juice Shop GitHub 仓库](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fjuice-shop%2Fjuice-shop)，使用 Docker 在本地拉起靶场：
    ```bash
    docker run --rm -p 3000:3000 bkimminich/juice-shop
    ```
  - 浏览器访问 `http://localhost:3000`，确认靶场正常运行。

## 3. 核心安全理论与靶场实操学习清单（Day 8–20）

第一阶段理论学习不求偏门二进制漏洞，重点攻克企业最常见的**权限绕过、敏感信息暴露、注入与安全配置缺陷**，直接支撑后续检测报告的专业度与咨询话术。

### 3.1 Web与API核心风险标准精读（Day 8–12）
- [ ] **通读 [OWASP Top 10:2025](https://www.google.com/search?q=https%3A%2F%2Fowasp.org%2FTop10%2F2025%2F) 核心风险项并做中文笔记**
  - 重点掌握 **A01:2025 访问控制失效（Broken Access Control）**：理解水平越权、垂直越权、未授权访问接口的成因与修复方案。
  - 重点掌握 **A02:2025 安全配置错误（Security Misconfiguration）**：理解默认账密、目录遍历、开启调试模式、云存储桶公开读写的检测特征。
  - 重点掌握 **A04:2025 加密机制失效与 A05:2025 注入（Injection）**：理解弱 TLS 协议、明文传输敏感数据、SQL 注入与命令注入。
- [ ] **精读 [OWASP API Security Top 10](https://www.google.com/search?q=https%3A%2F%2Fowasp.org%2FAPI-Security%2F)（现代小程序/前后端分离项目必考）**
  - 重点攻克 **API1 对象级授权失效（BOLA/IDOR）** 与 **API3 对象属性级授权失效（BOPLA）**：学会如何通过修改请求包中的 `user_id`、`order_id` 或多余 JSON 字段发现敏感数字资产泄漏。
  - 重点攻克 **API9 资产管理不当（Improper Inventory Management）**：理解为什么老旧版本接口（如 `/api/v1/export`、`/test/swagger-ui.html`）是企业数字资产泄漏的重灾区。
- [ ] **熟悉标准化检测清单框架**
  - 浏览 [OWASP WSTG 测试指南](https://www.google.com/search?q=https%3A%2F%2Fwstg.owasp.org%2F) 的“信息收集（Information Gathering）”与“配置管理测试”章节，提取标准测试步骤。
  - 下载并查阅 [OWASP ASVS 应用安全验证标准](https://www.google.com/search?q=https%3A%2F%2Fowasp.org%2Fprojects%2Fasvs)，学习如何将测试发现转化为咨询报告中的“标准化安全整改要求”。

### 3.2 在线靶场与本地靶场实操通关（Day 13–20）
- [ ] **注册并完成 [PortSwigger Web Security Academy](https://www.google.com/search?q=https%3A%2F%2Fportswigger.net%2Fweb-security) 核心 Apprentice（学徒级）实验**
  - 完成 **Access Control Vulnerabilities（访问控制与越权）** 模块至少 5 个实验。
  - 完成 **Authentication（认证缺陷与暴力破解防御）** 模块至少 4 个实验。
  - 完成 **Information Disclosure（敏感信息泄露：源码备份、调试页、Git 目录泄露）** 全部基础实验。
  - 完成 **SQL Injection（SQL注入）** 与 **SSRF（服务端请求伪造）** 基础识别实验。
- [ ] **在本地 [OWASP Juice Shop](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fjuice-shop%2Fjuice-shop) 完成实操演练**
  - 使用 Burp Suite 抓取登录与查询接口数据包，找出隐藏的得分板（Score Board）页面。
  - 练习发现暴露的 API 接口文档、未授权访问他人购物车/订单数据，并记录完整复现截图（作为后续编写商业检测报告的样例素材）。

## 4. 第一个 MVP 原型开发：外部数字资产暴露面体检脚本（Day 21–30）

将前 20 天所学的工具与理论串联为一个可复用的自动化脚本，实现“输入主域名 → 自动发现外部数字资产 → 筛选无害化检测项 → 生成中文 Markdown/HTML 体检报告”。

- [ ] **编写自定义 Nuclei 无害化检测模板（YAML DSL 练习）**
  - 阅读 [Nuclei Templates](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fnuclei-templates) 中现有的检测模板结构。
  - 动手编写 3 个无害化（只读、不破坏业务数据）自定义 YAML 模板：
    1. 检测目标网站是否意外暴露 `.git/config`、`.env` 或 `.DS_Store` 等核心数字资产文件。
    2. 检测目标是否暴露 Swagger/OpenAPI 接口文档页面（如 `/swagger-ui.html`、`/v2/api-docs`）。
    3. 检测目标 HTTP 响应头是否缺失关键安全防护头（如 `Strict-Transport-Security`、`X-Frame-Options`、`Content-Security-Policy`）。
- [ ] **开发 Python 自动化编排脚本（`easm_scanner.py`）**
  - 使用 Python `subprocess` 按顺序调用：
    1. 调用 [Subfinder](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fsubfinder) 收集子域名列表并去重。
    2. 调用 [httpx](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fhttpx) 提取存活站点、标题、Web 框架指纹及 SSL 证书过期剩余天数（标记剩余少于 15 天的证书风险）。
    3. 调用 [Nuclei](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2Fprojectdiscovery%2Fnuclei) 仅加载 `exposures`（信息暴露）、`misconfiguration`（配置错误）与 `ssl` 标签模板进行安全扫描，输出结构化 JSON 结果。
- [ ] **制作第一份《企业外部数字资产与暴露面安全体检报告》标准模板**
  - 设计报告结构，包含以下五个核心模块：
    1. **执行摘要（Executive Summary）**：外部资产总数、高/中/低危风险统计与整体安全健康度评分。
    2. **外部数字资产清册**：枚举发现的子域名、公网 IP、开放 Web 端口、识别到的技术栈与 SSL 证书到期时间表。
    3. **敏感暴露与脆弱性详情**：每项风险的资产 URL、风险等级、复现证据截图/数据包、业务危害说明。
    4. **合规与基线映射**：对标 [OWASP Top 10:2025](https://www.google.com/search?q=https%3A%2F%2Fowasp.org%2FTop10%2F2025%2F) 与 [GB/T 22239-2019 等保基本要求](https://www.google.com/search?q=https%3A%2F%2Fopenstd.samr.gov.cn%2Fbzgk%2Fstd%2FnewGbInfo%3Fhcno%3DBAFB47E8874764186BDB7865E8344DAF) 中“安全通信网络/安全计算环境”的对应条款说明。
    5. **分步修复建议**：面向客户运维/研发人员的可直接复制执行的配置加固指南（如 Nginx 隐藏版本号、屏蔽 `.git` 目录访问、接口鉴权修复示例）。

## 5. 第一阶段验收里程碑自检表（Day 30 复盘）

- [ ] 本地终端可随时调用 `subfinder`、`httpx`、`nuclei`，且模板库已更新至最新。
- [ ] 能够熟练使用 Burp Suite 或 ZAP 拦截并修改任意 Web/小程序 API 请求，独立验证越权与信息泄露漏洞。
- [ ] 已在 [PortSwigger Web Security Academy](https://www.google.com/search?q=https%3A%2F%2Fportswigger.net%2Fweb-security) 累计完成不少于 15 个实验靶场。
- [ ] 拥有 1 套自己编写的 Python 外部资产自动化体检脚本，并在本地靶场或自有合法域名上成功跑通，产出第 1 份完整的中文样板体检报告。
