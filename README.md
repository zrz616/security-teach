# Driftholm

网络安全与企业数据资产安全学习工作区，聚焦安全资讯、外部攻击面测绘和可复用的工具/API 原型。

## 当前内容

- `lessons/`：安全学习课程与练习
- `research/`、`docs/research/`：研究记录
- `tools/`：可复用工具与 Nuclei 模板
- `Dockerfile`、`compose.yaml`：包含 Python 3、ProjectDiscovery `subfinder`、`dnsx`、`httpx`、`katana` 和 `nuclei` 的本地执行环境
- `phase1_security_learning_and_setup_todo.md`：第一阶段学习与落地清单

## Docker 执行环境

先阅读 [docker/README.md](docker/README.md)，然后执行：

```bash
mkdir -p .scanner/input .scanner/output .scanner/nuclei-templates
docker compose build
docker compose run --rm scanner nuclei -duc -validate \
  -t /work/templates/astro-detect.yaml
```

该环境用于本地靶场或明确授权的目标，不要对未授权公网资产发起主动扫描。

## 安全边界

本仓库不包含 API key、访问令牌、私钥、扫描输出或本地 Agent 会话数据。所有外部目标测试都应先确认资产归属和书面授权。
