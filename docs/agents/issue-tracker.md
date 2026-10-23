# Issue tracker: Plane

本 repo 的 issue/spec 统一作为 Plane Work Items 管理：

- Workspace：`ydy-dev`
- Project：`Web/API 安全与外部资产测绘`
- Project identifier：`WEBAPI`
- Project UUID：`9ffd6c07-a318-4883-9bdd-25c809b5cbbf`
- Plane origin：`https://plane.metage.xyz`
- API credential：从 `.env` 的 `PLANE_API_KEY` 读取，绝不写入文档、日志或命令行参数。

## Conventions

- 创建、读取、更新 Work Item：使用仓库内的 [Plane API skill](../../.agents/skills/plane-api/SKILL.md) 和 Plane REST API `/api/v1/.../work-items/`。
- 创建 issue/spec：创建一个 Work Item，标题放在 `name`，正文通过 `description_html` 写入。Markdown 内容可在本地计划中保留为普通文本，但实际 API payload 不使用 `description` 字段。
- 获取相关 ticket：按 Work Item UUID 或项目内序号读取；需要跨页时遵循 Plane cursor pagination。
- 更新状态、负责人、优先级、标签：使用 Work Item update API。
- 父子任务：使用 Work Item 的 `parent` 字段。
- 不自动删除项目或批量删除 Work Items；破坏性操作需要单独明确授权。
- 外部 PR 不作为本 repo 的自动 triage 请求入口。

## API workflow

优先使用仓库内 [Plane API skill](../../.agents/skills/plane-api/SKILL.md) 提供的 `./.agents/skills/plane-api/scripts/plane_api.py`。API key 通过 `PLANE_API_KEY` 环境变量提供；不要从 `.env` 打印或复制 key。自托管 API base URL 使用 `https://plane.metage.xyz`，workspace slug 是 `ydy-dev`，project endpoint 使用 UUID 而不是 `WEBAPI`。

当 skill 说“发布到 issue tracker”时，创建 Plane Work Item；当 skill 说“获取相关 ticket”时，从该项目读取对应 Work Item。标签映射见 `docs/agents/triage-labels.md`。
