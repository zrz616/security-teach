# Docker 执行环境

这个 Compose 配置提供一个包含 Python 3、ProjectDiscovery `subfinder`、`dnsx`、`httpx`、`katana` 和 `nuclei` 的统一执行环境。默认只构建 scanner，不会启动靶场或执行扫描。

## 初始化

```bash
mkdir -p .scanner/input .scanner/output "$HOME/.nuclei/nuclei-templates"
docker compose build
```

宿主机即使使用 root 执行 Docker，也不要把容器 UID 设置为 0。保持容器使用非 root 的 `1000:1000`，由宿主机 root 只负责准备目录权限：

```bash
export SCANNER_UID=1000
export SCANNER_GID=1000
chown -R 1000:1000 "$HOME/.nuclei/nuclei-templates" .scanner/output
```

如果宿主机不是 root 且当前用户 UID/GID 不是 1000，再将 `SCANNER_UID` 和 `SCANNER_GID` 设置为该非 root 用户的实际 UID/GID。

## 验证工具

```bash
docker compose run --rm scanner subfinder -version
docker compose run --rm scanner dnsx -version
docker compose run --rm scanner httpx -version
docker compose run --rm scanner katana -version
docker compose run --rm scanner nuclei -version
docker compose run --rm scanner nuclei -duc \
  -validate -t /work/templates/astro-detect.yaml
```

`httpx` 命令是 ProjectDiscovery 版本，不是 Python 的 `httpx` 包。

## 更新官方模板

官方模板存放在宿主机的 `~/.nuclei/nuclei-templates`，本地仓库模板则挂载到 `/work/templates`：

```bash
docker compose run --rm scanner nuclei -update-templates -ud /tmp/nuclei-templates
```

建议把工具版本和模板更新时间记录到运行清单中，不要在每次扫描时无记录地自动更新。

运行正式联调前，必须先成功执行一次上面的模板更新命令；`-duc` 只关闭更新检查，不会下载模板。

## 本地 Juice Shop 联调

只在需要本地靶场时启用 `lab` profile：

```bash
docker compose --profile lab up -d juiceshop
docker compose run --rm scanner sh -lc '
  set -eu
  getent hosts juiceshop >/dev/null || {
    echo "juiceshop could not be resolved by Docker DNS" >&2
    exit 1
  }
  printf "%s\\n" "http://juiceshop:3000" \
    | httpx -silent \
    > /work/output/live-assets.txt
  test -s /work/output/live-assets.txt || {
    echo "httpx found no reachable Juice Shop URL" >&2
    exit 1
  }
  katana -silent -d 2 \
    -list /work/output/live-assets.txt \
    -o /work/output/crawled-urls.txt
  test -s /work/output/crawled-urls.txt || {
    echo "katana found no crawlable URL" >&2
    exit 1
  }
  test -d /tmp/nuclei-templates/http || {
    echo "official Nuclei templates are missing; run the update command first" >&2
    exit 1
  }
  nuclei -duc -jsonl \
    -l /work/output/crawled-urls.txt \
    -t /tmp/nuclei-templates/http/technologies/ \
    -t /tmp/nuclei-templates/http/exposures/ \
    -t /tmp/nuclei-templates/http/misconfiguration/ \
    -exclude-tags dos,fuzz,intrusive \
    -o /work/output/juiceshop-findings.jsonl
'
docker compose --profile lab down
```

Compose 网络内使用 `http://juiceshop:3000`；宿主机浏览器使用 `http://localhost:3000`。该环境只用于本地靶场或明确授权的目标，不要把主动扫描命令用于未授权公网资产。

Juice Shop 的首轮模板建议使用以下范围：

- `/http/technologies/`：识别框架和组件，替代对 Astro 专用模板的假设。
- `/http/exposures/`：检查常见敏感文件、接口文档和公开资产线索。
- `/http/misconfiguration/`：检查安全响应头等配置问题。

`astro-detect.yaml` 只适合在目标确实使用 Astro 时单独验证，不作为 Juice Shop 的默认模板。

## 使用输入文件

把授权目标放入 `.scanner/input/urls.txt` 后，可将结果写入 `.scanner/output`：

```bash
docker compose run --rm scanner httpx \
  -l /work/input/urls.txt \
  -title -tech-detect -status-code -json \
  -o /work/output/live-assets.jsonl

docker compose run --rm scanner nuclei \
  -l /work/input/urls.txt \
  -duc \
  -t /tmp/nuclei-templates/http/technologies/ \
  -t /tmp/nuclei-templates/http/exposures/ \
  -t /tmp/nuclei-templates/http/misconfiguration/ \
  -exclude-tags dos,fuzz,intrusive \
  -jsonl -o /work/output/juiceshop-findings.jsonl
```
