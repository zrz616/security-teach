#!/bin/sh
# Deterministic subfinder -> dnsx -> httpx -> katana -> nuclei pipeline.
# Always writes run-manifest.json, even when a step fails, so CI can inspect
# exit codes and partial artifacts.
set -u

OUT="${OUT:-/work/output}"
RUN="${RUN:-/work/run}"
TEMPLATES="${TEMPLATES:-/work/templates}"
OFFICIAL_DIR="${OFFICIAL_DIR:-/opt/nuclei-templates}"
SCOPE="${SCOPE:-}"
COMMIT="${COMMIT:-unknown}"
OFFICIAL="${OFFICIAL_TEMPLATES:-0}"
OFFICIAL_REF="${OFFICIAL_TEMPLATES_REF:-}"

STARTED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$OUT" "$RUN"
: > "$RUN/commands.txt"
printf '{}\n' > "$RUN/exit_codes.json"
: > "$RUN/versions.tsv"

# Required artifacts exist even if the pipeline fails before producing them.
: > "$OUT/subdomains.txt"
: > "$OUT/live-assets.jsonl"
: > "$OUT/katana-input.txt"
: > "$OUT/crawled-urls.txt"
: > "$OUT/nuclei-output.jsonl"

FATAL=0
ACTIVE=1
MODE=none
SCOPE_KIND=none
TEMPLATES="${TEMPLATES%/}"
SCOPE=$(printf '%s' "$SCOPE" | tr '[:upper:]' '[:lower:]')

say() { printf '%s\n' "$*" >&2; }
fail() {
  say "pipeline: $*"
  FATAL=1
}
record_cmd() { printf '%s\n' "$1" >> "$RUN/commands.txt"; }
record_rc() {
  case "$2" in
    ''|*[!0-9]*) say "pipeline: invalid exit code name=$1 value=[$2]" ;;
  esac
  jq --arg k "$1" --argjson v "$2" '. + {($k): $v}' \
    "$RUN/exit_codes.json" > "$RUN/exit_codes.json.tmp" \
    && mv "$RUN/exit_codes.json.tmp" "$RUN/exit_codes.json"
}
run_shell() {
  # run_shell <name> <command string>
  record_cmd "$2"
  sh -c "$2" > "$RUN/$1.stdout" 2> "$RUN/$1.stderr"
  rc=$?
  record_rc "$1" "$rc"
  return "$rc"
}
record_version() {
  # record_version <name> <version command>
  run_shell "version.$1" "$2"
  rc=$?
  raw=$(cat "$RUN/version.$1.stdout" "$RUN/version.$1.stderr" 2>/dev/null \
    | tr -d '\033' \
    | sed -E 's/\[[0-9;]*[A-Za-z]//g' || true)
  version=$(printf '%s\n' "$raw" | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
  [ -n "$version" ] || version=$(printf '%s\n' "$raw" | grep -m1 . || true)
  [ -n "$version" ] || version=unknown
  printf '%s\t%s\t%s\n' "$1" "$version" "$rc" >> "$RUN/versions.tsv"
}
in_scope() {
  host=$1
  if [ "$SCOPE_KIND" = "lab" ]; then
    case "$host" in
      localhost|127.*|::1|10.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*)
        return 0
        ;;
      *.*)
        return 1
        ;;
      *)
        return 0
        ;;
    esac
  fi
  case "$host" in
    "$SCOPE"|*."$SCOPE") return 0 ;;
  esac
  return 1
}
require_nonempty() {
  # require_nonempty <file> <label>
  if [ ! -s "$1" ]; then
    fail "$2 is empty ($1)"
    return 1
  fi
  return 0
}

# --- scope and inputs -------------------------------------------------------
case "$SCOPE" in
  "") fail "scope is required"; record_rc "scope" 2; ACTIVE=0 ;;
  lab://*)
    SCOPE_KIND=lab
    ;;
  *://*)
    fail "scope must be a domain (for example example.com), not a URL"
    record_rc "scope" 2
    ACTIVE=0
    ;;
  *.*)
    SCOPE_KIND=domain
    case "$SCOPE" in
      .*|*.|*..*|*[!a-z0-9.-]*)
        fail "scope is not a valid domain: $SCOPE"
        record_rc "scope" 2
        ACTIVE=0
        ;;
    esac
    ;;
  *)
    fail "scope must be an authorized domain or lab://<lab>"
    record_rc "scope" 2
    ACTIVE=0
    ;;
esac

if [ -f /work/input/targets.txt ]; then
  MODE=targets
  grep -vE '^[[:space:]]*(#|$)' /work/input/targets.txt > "$RUN/targets.txt" || true
  if [ -s "$RUN/targets.txt" ]; then
    sed -E \
      -e 's#^[A-Za-z][A-Za-z0-9+.-]*://##' \
      -e 's#^[^/]*@##' \
      -e 's#^\[([^]]+)\].*#\1#' \
      -e 's#^([^/:]+).*#\1#' \
      "$RUN/targets.txt" \
      | tr '[:upper:]' '[:lower:]' \
      | sort -u > "$OUT/subdomains.txt"
  else
    fail "targets file has no usable target"
    ACTIVE=0
  fi
elif [ -f /work/input/subdomains.txt ]; then
  MODE=subdomains
  grep -vE '^[[:space:]]*(#|$)' /work/input/subdomains.txt \
    | sed -E 's/^[[:space:]]*\*\.?//; s/[[:space:]]*$//' \
    | tr '[:upper:]' '[:lower:]' \
    | sort -u > "$OUT/subdomains.txt"
else
  MODE=subfinder
fi

if [ "$MODE" = "subfinder" ]; then
  if [ "$SCOPE_KIND" != "domain" ]; then
    fail "subfinder mode requires an authorized domain scope"
    ACTIVE=0
  elif [ "$ACTIVE" -eq 1 ]; then
    run_shell subfinder "subfinder -d $SCOPE -silent -timeout 15 -o $RUN/subfinder.txt"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      fail "subfinder exited $rc"
    fi
    if [ -s "$RUN/subfinder.txt" ]; then
      grep -vE '^[[:space:]]*(#|$)' "$RUN/subfinder.txt" \
        | tr '[:upper:]' '[:lower:]' \
        | sort -u > "$OUT/subdomains.txt"
    else
      fail "subfinder returned no subdomains"
    fi
  fi
fi

# Refuse to scan anything outside the authorized scope.
if [ "$ACTIVE" -eq 1 ]; then
  BAD=0
  while IFS= read -r host; do
    [ -n "$host" ] || continue
    if ! in_scope "$host"; then
      fail "out-of-scope host: $host"
      record_rc "scope" 3
      BAD=1
    fi
  done < "$OUT/subdomains.txt"
  [ "$BAD" -eq 0 ] || ACTIVE=0
fi

if [ "$ACTIVE" -eq 1 ]; then
  if ! require_nonempty "$OUT/subdomains.txt" "subdomains.txt"; then
    record_rc "subdomains" 4
    ACTIVE=0
  fi
fi

# --- tool versions ----------------------------------------------------------
record_version subfinder "subfinder -version"
record_version dnsx "dnsx -version"
record_version httpx "httpx -version"
record_version katana "katana -version"
record_version nuclei "nuclei -version"

# --- resolution / probing ---------------------------------------------------
if [ "$ACTIVE" -eq 1 ] && [ "$MODE" != "targets" ]; then
  run_shell dnsx "dnsx -l $OUT/subdomains.txt -silent -a -resp -o $RUN/dnsx.txt"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    say "pipeline: warning: dnsx exited $rc; httpx will resolve directly"
  fi
fi

if [ "$ACTIVE" -eq 1 ]; then
  HTTPX_INPUT="$OUT/subdomains.txt"
  [ "$MODE" = "targets" ] && HTTPX_INPUT="$RUN/targets.txt"
  run_shell httpx "httpx -l $HTTPX_INPUT -silent -json -title -tech-detect -status-code -tls-grab -no-color -threads 10 -rate-limit 20 -timeout 10 -retries 1 -o $OUT/live-assets.jsonl"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "httpx exited $rc"
    ACTIVE=0
  fi
  if [ "$rc" -eq 0 ]; then
    require_nonempty "$OUT/live-assets.jsonl" "live-assets.jsonl" || ACTIVE=0
    if [ -s "$OUT/live-assets.jsonl" ]; then
      jq -e 'type == "object"' "$OUT/live-assets.jsonl" >/dev/null 2>&1 \
        || fail "live-assets.jsonl is not valid JSONL"
    fi
  fi
fi

if [ "$ACTIVE" -eq 1 ]; then
  jq -R -r 'fromjson? | select(type == "object") | .url // empty' \
    "$OUT/live-assets.jsonl" | sort -u > "$OUT/katana-input.txt"
  require_nonempty "$OUT/katana-input.txt" "katana-input.txt" || ACTIVE=0
fi

if [ "$ACTIVE" -eq 1 ]; then
  run_shell katana "katana -list $OUT/katana-input.txt -silent -d 2 -c 10 -p 5 -rl 20 -timeout 10 -o $OUT/crawled-urls.txt"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "katana exited $rc"
    ACTIVE=0
  fi
  if [ "$rc" -eq 0 ]; then
    require_nonempty "$OUT/crawled-urls.txt" "crawled-urls.txt" || ACTIVE=0
  fi
fi

# --- templates and detections ----------------------------------------------
LOCAL_TEMPLATE_COUNT=0
if [ -d "$TEMPLATES" ]; then
  LOCAL_TEMPLATE_COUNT=$(find "$TEMPLATES" -type f \( -name '*.yaml' -o -name '*.yml' \) | wc -l | tr -d ' ')
fi

if [ "$ACTIVE" -eq 1 ]; then
  if [ "$LOCAL_TEMPLATE_COUNT" -eq 0 ]; then
    fail "no local nuclei templates in $TEMPLATES"
    ACTIVE=0
  else
    run_shell template.validate "nuclei -duc -validate -t $TEMPLATES"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      fail "nuclei template validation exited $rc"
      ACTIVE=0
    fi
  fi
fi

if [ "$ACTIVE" -eq 1 ]; then
  NUCLEI_CMD="nuclei -duc -no-interactsh -jsonl -l $OUT/crawled-urls.txt -t $TEMPLATES -exclude-tags dos,fuzz,intrusive -rl 20 -c 10 -timeout 10 -o $OUT/nuclei-output.jsonl"
  if [ "$OFFICIAL" = "1" ] && [ -d "$OFFICIAL_DIR/http" ]; then
    NUCLEI_CMD="$NUCLEI_CMD -t $OFFICIAL_DIR/http/technologies/ -t $OFFICIAL_DIR/http/exposures/ -t $OFFICIAL_DIR/http/misconfiguration/"
  fi
  run_shell nuclei "$NUCLEI_CMD"
  rc=$?
  [ "$rc" -eq 0 ] || fail "nuclei exited $rc"
  if [ -s "$OUT/nuclei-output.jsonl" ]; then
    jq -e 'type == "object"' "$OUT/nuclei-output.jsonl" >/dev/null 2>&1 \
      || fail "nuclei-output.jsonl is not valid JSONL"
  fi
fi

# --- manifest ---------------------------------------------------------------
TOOLS_JSON='{}'
while IFS="$(printf '\t')" read -r name version rc; do
  [ -n "$name" ] || continue
  TOOLS_JSON=$(jq -n \
    --argjson acc "$TOOLS_JSON" \
    --arg n "$name" \
    --arg v "$version" \
    --argjson rc "$rc" \
    '$acc + {($n): {version: $v, exit_code: $rc}}')
done < "$RUN/versions.tsv"

LOCAL_FILES_JSON='{}'
if [ -d "$TEMPLATES" ]; then
  LOCAL_FILES_JSON=$(find "$TEMPLATES" -type f \( -name '*.yaml' -o -name '*.yml' \) \
    | sort \
    | while IFS= read -r f; do
        rel=${f#"$TEMPLATES"/}
        printf '%s\t%s\n' "$rel" "$(sha256sum "$f" | awk '{print $1}')"
      done \
    | jq -Rn '[inputs | split("\t") | {(.[0]): .[1]}] | add // {}')
fi

OFFICIAL_JSON='null'
if [ "$OFFICIAL" = "1" ] && [ -d "$OFFICIAL_DIR" ]; then
  OFFICIAL_COUNT=$(find "$OFFICIAL_DIR" -type f \( -name '*.yaml' -o -name '*.yml' \) | wc -l | tr -d ' ')
  OFFICIAL_JSON=$(jq -n --arg ref "$OFFICIAL_REF" --argjson count "$OFFICIAL_COUNT" '{ref: $ref, count: $count}')
fi

TEMPLATES_JSON=$(jq -n \
  --argjson local_files "$LOCAL_FILES_JSON" \
  --argjson local_count "$LOCAL_TEMPLATE_COUNT" \
  --argjson official "$OFFICIAL_JSON" \
  '{local: {path: "tools/nuclei", count: $local_count, files: $local_files}, official: $official}')

COMMANDS_JSON=$(jq -R -s 'split("\n") | map(select(length > 0))' "$RUN/commands.txt")

SUBDOMAINS_INPUT=false
TARGETS_INPUT=false
[ -f /work/input/subdomains.txt ] && SUBDOMAINS_INPUT=true
[ -f /work/input/targets.txt ] && TARGETS_INPUT=true

INPUTS_JSON=$(jq -n \
  --arg scope "$SCOPE" \
  --arg mode "$MODE" \
  --argjson subdomains_file "$SUBDOMAINS_INPUT" \
  --argjson targets_file "$TARGETS_INPUT" \
  --arg templates "$TEMPLATES" \
  --argjson official_templates "$([ "$OFFICIAL" = "1" ] && echo true || echo false)" \
  '{scope: $scope, mode: $mode, subdomains_file: $subdomains_file, targets_file: $targets_file, templates_dir: $templates, official_templates: $official_templates}')

OUTPUTS_JSON=$(for f in subdomains.txt live-assets.jsonl katana-input.txt crawled-urls.txt nuclei-output.jsonl; do
  if [ -f "$OUT/$f" ]; then
    bytes=$(wc -c < "$OUT/$f" | tr -d ' ')
    sha=$(sha256sum "$OUT/$f" | awk '{print $1}')
    jq -n --arg f "$f" --argjson b "$bytes" --arg s "$sha" '{($f): {bytes: $b, sha256: $s}}'
  fi
done | jq -s 'add // {}')

json_valid() {
  printf '%s' "$2" | jq -e . >/dev/null 2>&1 \
    || say "pipeline: invalid JSON for $1: [$2]"
}
json_valid tools "$TOOLS_JSON"
json_valid templates "$TEMPLATES_JSON"
json_valid commands "$COMMANDS_JSON"
json_valid inputs "$INPUTS_JSON"
json_valid outputs "$OUTPUTS_JSON"

FINISHED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq -n \
  --arg scope "$SCOPE" \
  --arg commit "$COMMIT" \
  --argjson tools "$TOOLS_JSON" \
  --argjson templates "$TEMPLATES_JSON" \
  --argjson commands "$COMMANDS_JSON" \
  --argjson inputs "$INPUTS_JSON" \
  --argjson outputs "$OUTPUTS_JSON" \
  --argjson exit_codes "$(cat "$RUN/exit_codes.json")" \
  --arg started_at "$STARTED_AT" \
  --arg finished_at "$FINISHED_AT" \
  '{scope: $scope, commit: $commit, tools: $tools, templates: $templates, commands: $commands, inputs: $inputs, outputs: $outputs, exit_codes: $exit_codes, started_at: $started_at, finished_at: $finished_at}' \
  > "$OUT/run-manifest.json" || fail "could not write run-manifest.json"

jq -e '
  type == "object"
  and has("scope") and has("commit") and has("tools") and has("templates")
  and has("commands") and has("inputs") and has("outputs")
  and has("exit_codes") and has("started_at") and has("finished_at")
  and (.tools | type == "object")
  and (.templates | type == "object")
  and (.commands | type == "array")
  and (.exit_codes | type == "object")
' "$OUT/run-manifest.json" >/dev/null 2>&1 || fail "run-manifest.json is malformed"

if [ "$FATAL" -ne 0 ]; then
  say "pipeline: finished with errors; see run-manifest.json"
  exit 1
fi
say "pipeline: completed"
exit 0
