# Dagger CI：WEBAPI-5 资产测绘流水线

`ci/` 是 Dagger Go 模块，复用根目录 `Dockerfile` 构建统一 scanner 镜像，执行：

```text
subfinder -> dnsx -> httpx -> katana -> nuclei
```

并把结果写成 `artifacts/webapi-5/`：

```text
subdomains.txt
live-assets.jsonl
katana-input.txt
crawled-urls.txt
nuclei-output.jsonl
run-manifest.json
```

## 验证（不发公网请求）

`verify` 在 scanner 容器内启动 `127.0.0.1:8080` 的 HTTP fixture，串联全部工具生成六件产物：

```bash
dagger call -m ci verify export --path artifacts/webapi-5
dagger call -m ci check --artifacts artifacts/webapi-5
```

`check` 读取 `run-manifest.json`，任何命令退出码非 0、工具版本缺失或必要产物为空都会失败。

## 授权目标

`scope` 必填。只接受受权域名，或以 `lab://` 开头的靶场标识：

```bash
dagger call -m ci artifacts \
  --scope example.com \
  --commit "$(git rev-parse HEAD)" \
  export --path artifacts/webapi-5
dagger call -m ci check --artifacts artifacts/webapi-5
```

流水线会在发出任何主动请求前校验输入主机是否等于 `scope` 或是其子域；越界主机直接终止该轮扫描。默认速率限制为 20 req/s、10 并发，并排除 `dos,fuzz,intrusive` 模板。

### 使用预先批准的子域清单

跳过 `subfinder`，但仍会校验每个主机属于 `scope`：

```bash
dagger call -m ci artifacts \
  --scope example.com \
  --subdomains .scanner/input/subdomains.txt \
  export --path artifacts/webapi-5
```

### 使用本地靶场或已授权 URL

`--targets` 跳过 `subfinder` 和 `dnsx`，直接以 URL 作为 httpx 输入。`scope` 用 `lab://` 表示本地靶场；该模式只接受 loopback、私网或单标签主机（如 `juiceshop`），公网 FQDN 必须走域名 scope：

```bash
dagger call -m ci artifacts \
  --scope lab://juice-shop \
  --targets .scanner/input/targets.txt \
  export --path artifacts/webapi-5
```

### 官方模板

默认只加载仓库内 `tools/nuclei/`。额外加载固定版本 `nuclei-templates`（technologies / exposures / misconfiguration）：

```bash
dagger call -m ci artifacts \
  --scope example.com \
  --official-templates=true \
  export --path artifacts/webapi-5
```

## run-manifest.json

```json
{
  "scope": "example.com",
  "commit": "9bf5b95",
  "tools": {
    "subfinder": { "version": "v2.17.0", "exit_code": 0 }
  },
  "templates": {
    "local": { "path": "tools/nuclei", "count": 1, "files": {} },
    "official": null
  },
  "commands": [],
  "inputs": {},
  "outputs": {
    "subdomains.txt": { "bytes": 123, "sha256": "..." }
  },
  "exit_codes": {},
  "started_at": "2026-10-29T00:00:00Z",
  "finished_at": "2026-10-29T00:00:00Z"
}
```

`tools` 记录实际二进制版本；`templates.local.files` 记录模板文件 SHA-256；`outputs` 记录五件数据文件的字节数与 SHA-256；`run-manifest.json` 本身不计入 `outputs`，避免自引用。

## 用仓库外 targets 运行

targets 是运行输入，不是源码，**不要提交到仓库**。默认读取被 gitignore 的 `.scanner/input/targets.txt`：

```bash
mkdir -p .scanner/input
# 写入授权目标，每行一个 URL
SCOPE=example.com ./ci/run.sh
```

本地 loopback smoke test：

```bash
printf 'http://127.0.0.1:8080
' > .scanner/input/targets.txt
SCOPE=lab://webapi-5-fixture LOCAL_FIXTURE=1 ./ci/run.sh
```

CI 中把 targets 作为 secret/artifact 挂载，然后：

```bash
SCOPE=example.com TARGETS=/secure/targets.txt ./ci/run.sh
```

`ci/run.sh` 会导出 `artifacts/webapi-5/` 并自动执行 `check`。

## 安全边界

- 只对自有或已取得书面授权的资产运行。
- 不接受 URL 形式的 `scope`；授权范围只能是域名。
- `--targets` 中的主机同样受 `scope` 校验，`lab://` 仅用于本地靶场。
- targets 与扫描产物都不应提交到仓库；`targets.txt` 通过外部路径或 CI secret 提供。

## 修改函数签名后

`ci/.dagger/dagger.gen.go` 是生成文件；`dag` 由它定义，不能单独编译 `main.go`。

改动 `main.go` 中导出函数的参数或返回类型后，先重新生成再编译：

```bash
dagger develop -m ci
cd ci/.dagger && go build ./...
```

不要用 `go run main.go` 或 `go build main.go`：这会漏掉生成文件，报 `undefined: dag`。
