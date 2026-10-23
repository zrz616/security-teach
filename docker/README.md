# Docker 执行环境

这个 Compose 配置提供一个包含 Python 3、ProjectDiscovery `subfinder`、ProjectDiscovery `httpx` 和 `nuclei` 的统一执行环境。默认只构建 scanner，不会启动靶场或执行扫描。

## 初始化

```bash
mkdir -p .scanner/input .scanner/output .scanner/nuclei-templates
docker compose build
```

如果宿主机 UID/GID 不是 1000，运行命令时显式传入当前用户的 UID/GID，避免输出文件无法写入：

```bash
export SCANNER_UID="$(id -u)"
export SCANNER_GID="$(id -g)"
```

## 验证工具

```bash
docker compose run --rm scanner subfinder -version
docker compose run --rm scanner httpx -version
docker compose run --rm scanner nuclei -version
docker compose run --rm scanner nuclei -validate -t /work/templates/astro-detect.yaml
```

`httpx` 命令是 ProjectDiscovery 版本，不是 Python 的 `httpx` 包。

## 更新官方模板

官方模板存放在被忽略的 `.scanner/nuclei-templates`，本地仓库模板则挂载到 `/work/templates`：

```bash
docker compose run --rm scanner nuclei -update-templates -ud /tmp/nuclei-templates
```

建议把工具版本和模板更新时间记录到运行清单中，不要在每次扫描时无记录地自动更新。

## 本地 Juice Shop 联调

只在需要本地靶场时启用 `lab` profile：

```bash
docker compose --profile lab up -d juiceshop
docker compose run --rm scanner httpx \
  -u http://juiceshop:3000 \
  -title -tech-detect -status-code -json
docker compose run --rm scanner nuclei \
  -u http://juiceshop:3000 \
  -t /work/templates/astro-detect.yaml \
  -jsonl
docker compose --profile lab down
```

Compose 网络内使用 `http://juiceshop:3000`；宿主机浏览器使用 `http://localhost:3000`。该环境只用于本地靶场或明确授权的目标，不要把主动扫描命令用于未授权公网资产。

## 使用输入文件

把授权目标放入 `.scanner/input/urls.txt` 后，可将结果写入 `.scanner/output`：

```bash
docker compose run --rm scanner httpx \
  -l /work/input/urls.txt \
  -title -tech-detect -status-code -json \
  -o /work/output/live-assets.jsonl

docker compose run --rm scanner nuclei \
  -l /work/input/urls.txt \
  -t /work/templates/astro-detect.yaml \
  -jsonl -o /work/output/astro-findings.jsonl
```
