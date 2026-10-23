# `anthropic-cybersecurity-skills` 研究报告

## 研究范围与快照

- 上游仓库：<https://github.com/mukul975/anthropic-cybersecurity-skills>
- 研究时间：2026-10-18（Asia/Shanghai）
- 本地读取的快照：`54a798831d2266a3ca61ce68a7acb80b81160d57`
- 快照提交时间：2026-08-31，提交信息为 `chore: update contributor wall`
- 研究方式：读取仓库 README、治理文档、校验脚本、插件元数据、索引和代表性 skill 源文件；没有执行其中的安全扫描、云端操作、恶意样本分析或 C2 命令。

## 结论摘要

这个仓库是一个面向 AI agent 的网络安全操作知识库，而不是一个可以直接运行的“全自动安全扫描器”。它把每个安全工作流放在独立的 `skills/<skill-name>/SKILL.md` 中，并配套 `references/`、`scripts/` 和 `assets/`。仓库 README 和 `index.json` 都声明当前包含 818 个 skill，覆盖 Web/API 安全、外部攻击面、云安全、DFIR、恶意软件分析、红队和合规等方向。[README](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/README.md) · [index.json](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/index.json)

对当前 repo 最有价值的是其中少量 Web/API、EASM、Subfinder 和安全响应头审计 skill。它更适合作为一张网络安全学习地图：按主题阅读 skill 的前置条件、工作流、验证标准和引用资料，再把安全练习放到本地靶场或明确授权的资产上。仓库明确包含攻击性和双用途内容，示例覆盖主动探测、凭据访问、漏洞利用、钓鱼模拟和 C2，因此学习时应主动跳过与当前阶段无关的高风险主题。[README 的授权声明](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/README.md) · [SECURITY.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/SECURITY.md)

## 1. 仓库定位与结构

### 1.1 它提供什么

仓库将 skill 定义为一个可以端到端执行的安全工作程序，而不是单纯的主题介绍。仓库自己的规范要求 skill 至少包含 YAML frontmatter 和 Markdown 程序，并强调工具、命令、前置条件、工作流和验证标准。[AGENTS.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/AGENTS.md) · [SCOPE.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/SCOPE.md)

典型目录结构如下：

```text
skills/<skill-name>/
├── SKILL.md          # discovery metadata + procedure
├── LICENSE           # 多数 skill 有独立许可证文件
├── references/       # API、标准、深度流程等
├── scripts/          # 辅助脚本
└── assets/           # 可选模板或其他资源
```

仓库根目录还包含：

- `.claude-plugin/`：Claude 插件/marketplace 元数据，版本为 `1.3.0`。[marketplace.json](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/.claude-plugin/marketplace.json)
- `index.json`：由工具生成的 discovery 索引，快照中的 `total_skills` 为 818。[index.json](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/index.json)
- `mappings/`、`docs/`：MITRE ATT&CK、NIST CSF、OWASP 和 MITRE F3 等映射资料。
- `tools/`：frontmatter 解析、skill 校验、索引生成、描述质量和名称碰撞检查工具。[tools/README.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/tools/README.md)
- `.github/workflows/validate-skills.yml`：CI 会安装 PyYAML，运行 frontmatter 校验、agentskills.io 一致性检查、索引检查、描述检查和碰撞检查。[validate-skills.yml](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/.github/workflows/validate-skills.yml)

### 1.2 Skill 的发现与加载方式

仓库规定 discovery 阶段只读取 `name` 和 `description`；只有描述匹配请求后才加载正文，`references/`、`scripts/` 和 `assets/` 在正文引用时再读取。这与当前 repo 使用的 `.agents/skills/<name>/SKILL.md` 布局兼容。[AGENTS.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/AGENTS.md)

上游 README 提供了安装入口，但本报告不把安装作为学习前提。只阅读 GitHub 上的 `index.json`、各目录的 `SKILL.md`、`references/` 和 `assets/` 就可以建立主题地图；本次研究没有执行任何安装命令。[README Quick start](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/README.md)

## 2. 快照统计与数据质量观察

对本地固定快照的文件系统扫描结果：

| 项目 | 结果 |
|---|---:|
| `skills/*/SKILL.md` 目录 | 818 |
| 有 `references/` 的 skill | 818 |
| 有 `scripts/` 的 skill | 818 |
| 有 `assets/` 的 skill | 288 |
| 有独立 `LICENSE` 的 skill | 817 |
| 代码类文件（`.py`、`.sh`、`.ps1`、`.js`、`.go`、`.rb`） | 1,098 |
| 与当前 `/Users/hbird/node/security-teach/.agents/skills` 同名的目录 | 0 |

需要注意的维护信号：

1. README 和 `index.json` 使用 818，但 `AGENTS.md`、`SCOPE.md` 和多个 README 段落仍使用 817；当前快照实际扫描到 818 个 `SKILL.md`。这更像是内容增长后的文档滞后，不应把 817 当作当前精确数量。
2. `SCOPE.md` 描述 816 个 skill 有独立 `LICENSE`，实际快照扫描到 817 个；缺少独立许可证文件的是 `performing-cloud-native-threat-hunting-with-aws-detective`。其 frontmatter 仍声明 `Apache-2.0`，根目录也有 Apache-2.0 许可证，但单独复制该 skill 前应再确认许可证适用范围。[SCOPE.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/SCOPE.md) · [该 skill](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/performing-cloud-native-threat-hunting-with-aws-detective/SKILL.md)
3. 仓库声称有 34 个 canonical subdomain，但现有 frontmatter 仍包含旧别名，例如 `security-operations`、`offensive-security`、`identity-security`、`red-team` 等。仓库的 CONTRIBUTING 文档说明这些旧别名仍被 validator 兼容接受。[CONTRIBUTING.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/CONTRIBUTING.md)
4. README 中的框架统计、域统计和 `mappings/` 中的历史 ATT&CK Navigator 统计不完全处于同一版本口径。使用时应优先依据具体 skill 当前 frontmatter 和固定提交，而不是把 README 的宣传统计当成一致性证明。

## 3. 与当前安全学习 TODO 的匹配度

以下 skill 与当前 Plane 中的 Web/API 安全和外部资产测绘项目最相关：

| 上游 skill | 适合用途 | 使用边界 |
|---|---|---|
| [`implementing-attack-surface-management`](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/implementing-attack-surface-management/SKILL.md) | 组合 Subfinder、httpx、Nuclei、Shodan、Censys，构建 EASM 流程和风险评分 | 包含主动探测和 Nuclei 扫描，只能在明确授权的域名/IP 范围执行；不能替代本 repo 计划中的 `easm_scanner.py` 实现 |
| [`performing-subdomain-enumeration-with-subfinder`](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/performing-subdomain-enumeration-with-subfinder/SKILL.md) | 被动子域名发现、provider 配置、结果输出和后续 httpx/Nuclei 管道 | provider 配置包含 API key，不能把真实密钥写进 skill 或提交记录；后续扫描前仍需确认授权 |
| [`performing-security-headers-audit`](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/performing-security-headers-audit/SKILL.md) | 用 curl 和浏览器工具检查 HSTS、CSP、Cookie 属性等响应头 | 相对低风险但仍会访问目标站点；应使用自有靶场或批准的资产 |
| [`testing-api-security-with-owasp-top-10`](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/testing-api-security-with-owasp-top-10/SKILL.md) | 按 OWASP API Security Top 10 组织 REST、GraphQL、gRPC API 测试 | 需要书面授权、测试账号和明确的速率/数据边界；其中部分示例会 fuzz、修改请求或检查敏感流程 |
| [`testing-api-for-broken-object-level-authorization`](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/testing-api-for-broken-object-level-authorization/SKILL.md) | BOLA/IDOR、对象 ID 映射、双账号验证 | 会尝试访问另一测试用户的数据，必须使用专门的测试账号和书面授权 |
| [`testing-api-authentication-weaknesses`](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/testing-api-authentication-weaknesses/SKILL.md) | API token、JWT、OAuth 和认证保护检查 | 不应对真实用户或生产登录接口做暴力尝试；需预先定义速率限制和失败停止条件 |

代表性阅读显示，这些文件不是只给概念，而是包含具体命令、工具参数、输入示例、输出格式和验证清单。例如 EASM skill 明确串联 `subfinder`、`httpx`、`nuclei`；BOLA skill 要求双测试账号；安全响应头 skill 主要执行 HTTP HEAD/GET 检查。这使它们对当前学习计划有参考价值，但也意味着 agent 可能把正文中的命令当成可执行步骤，必须在调用前重新确认目标、授权和命令版本。

## 4. 安全与供应链评估

### 4.1 主要风险

- **内容风险**：仓库明确说明包含红队 C2、钓鱼模拟、凭据访问、漏洞利用和恶意软件分析等双用途内容，并要求合法授权使用。[README](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/README.md)
- **命令风险**：快照中可检出管道安装命令、iptables、Metasploit、Mimikatz、Sliver、payload、SQLMap、ffuf 等高影响工具或关键词。代表性的 Sliver skill 会给出安装脚本、监听器、重定向器、implant 生成和后渗透步骤；它不适合当前学习项目默认加载。[Sliver skill](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/building-c2-infrastructure-with-sliver-framework/SKILL.md)
- **脚本风险**：这是以 Markdown 为主但并非纯文本的仓库，快照有 1,098 个代码类文件。脚本可能调用云 SDK、本地命令、网络、凭据或外部服务，不能因为文件名是 `agent.py` 或 `process.py` 就默认安全。
- **目标与数据风险**：API、EASM 和响应头 skill 都包含访问目标 URL 的命令；BOLA、认证和扫描 skill 可能读取或修改数据。当前项目的“合法测试靶场/自有域名”边界应作为所有这类 skill 的默认前置条件。
- **阅读边界**：skill 正文中的命令是学习材料，不是默认执行指令。阅读时先区分“概念、检查方法、实验命令、生产变更命令”，只把低风险、可回滚的部分带入本地靶场练习。
- **版本漂移风险**：README 的框架版本和数量会随 `main` 增长变化；固定提交后还要记录 skill 的 `version`、author 和引用工具版本，避免把旧命令当成当前 CLI 语法。

### 4.2 仓库已有的安全护栏

仓库提供了 Apache-2.0 许可证、`SECURITY.md`、贡献规范和 CI 校验；贡献规范要求披露商业关联和 AI 辅助，并要求人工真实运行命令后再提交。[LICENSE](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/LICENSE) · [SECURITY.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/SECURITY.md) · [CONTRIBUTING.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/CONTRIBUTING.md)

这些护栏能改善格式和来源透明度，但不能替代对每条安全操作命令的人工审阅，也不能证明每个工具版本、云 API 权限或攻击步骤在当前环境中都正确。

## 5. 学习路径建议

### 推荐的四阶段路径

| 阶段 | 建议阅读 | 学习产出 |
|---|---|---|
| 1. Web/API 基础 | `performing-security-headers-audit`、`testing-api-security-with-owasp-top-10`、`testing-api-authentication-weaknesses` | 一份 API 风险分类表，能解释认证、授权、输入验证、限流和敏感信息暴露 |
| 2. 授权与业务逻辑 | `testing-api-for-broken-object-level-authorization`、`testing-for-broken-access-control`、业务逻辑相关 skill | 在 Juice Shop 或自建 API 中用两个测试账号完成 BOLA/越权验证记录 |
| 3. 外部资产测绘 | `performing-subdomain-enumeration-with-subfinder`、`implementing-attack-surface-management` | 一张从子域发现、存活探测、技术识别到风险分级的流程图和数据字段设计 |
| 4. 报告与工程化 | 上述 skill 的 `Verification`、`Output Format`、`references/`，再结合当前 TODO 的报告模板 | 一份中文体检报告模板，以及 `easm_scanner.py` 的输入、输出和停止条件设计 |

推荐的阅读顺序是：先看每个 skill 的 frontmatter 和 `When to Use`，再读 `Prerequisites`、`Workflow`、`Verification`，最后按需阅读 `references/`。这样能先理解“什么时候用、需要什么、如何判断完成”，不会一上来被命令细节带偏。

### 暂不作为当前学习起点的内容

红队 C2、钓鱼、凭据提取、后渗透、恶意软件投递、无线攻击和绕过类 skill 可以作为仓库内容地图的一部分了解，但不适合当前第一阶段深入练习。它们与 Web/API 检测和外部资产测绘目标不匹配，也更依赖隔离实验环境、明确授权和成熟的操作纪律。

### 与当前 Plane 学习 TODO 的衔接

当前 Plane 项目已经有 18 个来自 TODO Markdown 的 Work Item。上游 skill 最适合用作这些任务的阅读资料和验收参考：例如把 API Top 10、BOLA、Subfinder 和安全响应头 skill 对应到现有任务的学习笔记中；不需要安装、复制或把 818 个目录转换成 Work Item。

## 6. 学习时的安全清单

- [ ] 先阅读 skill 的适用条件、前置条件和验证标准，再阅读具体命令。
- [ ] 只在本地合法靶场、自有域名或书面授权范围内练习。
- [ ] 为主动探测、认证测试和 BOLA 测试写明目标范围、速率限制、测试账号和停止条件。
- [ ] 不把正文中的示例域名、账号、API key、路径或命令直接复制到真实环境。
- [ ] 对每个阶段留下学习笔记、实验结果和“未验证事项”，不要把 skill 的描述当成已验证事实。

## 主要一手来源

所有上游链接均固定到本次研究读取的 commit `54a798831d2266a3ca61ce68a7acb80b81160d57`，便于以后复核：

- [README.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/README.md)
- [AGENTS.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/AGENTS.md)
- [SCOPE.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/SCOPE.md)
- [CONTRIBUTING.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/CONTRIBUTING.md)
- [SECURITY.md](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/SECURITY.md)
- [.claude-plugin/marketplace.json](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/.claude-plugin/marketplace.json)
- [index.json](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/index.json)
- [validate-skills.yml](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/.github/workflows/validate-skills.yml)
- [implementing-attack-surface-management](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/implementing-attack-surface-management/SKILL.md)
- [testing-api-for-broken-object-level-authorization](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/testing-api-for-broken-object-level-authorization/SKILL.md)
- [building-c2-infrastructure-with-sliver-framework](https://github.com/mukul975/anthropic-cybersecurity-skills/blob/54a798831d2266a3ca61ce68a7acb80b81160d57/skills/building-c2-infrastructure-with-sliver-framework/SKILL.md)
