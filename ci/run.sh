#!/usr/bin/env bash
# Run the WEBAPI-5 pipeline against an external targets file.
#
# Targets are run input, not source code: do NOT commit them. By default this
# reads the gitignored .scanner/input/targets.txt (the same path used by the
# Docker Compose workflow). CI should pass a secret/artifact path via TARGETS.
#
# Usage:
#   SCOPE=lab://webapi-5-fixture ./ci/run.sh
#   SCOPE=example.com TARGETS=/secure/targets.txt ./ci/run.sh
#   SCOPE=lab://webapi-5-fixture LOCAL_FIXTURE=1 ./ci/run.sh
#
# SCOPE is required. Public targets must be covered by the authorized scope;
# the pipeline rejects hosts outside it before scanning.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAGGER="${DAGGER:-dagger}"
SCOPE="${SCOPE:-}"
TARGETS="${TARGETS:-.scanner/input/targets.txt}"
OUT="${OUT:-artifacts/webapi-5}"
COMMIT="${COMMIT:-$(git -C "$ROOT" rev-parse HEAD)}"

if [ -z "$SCOPE" ]; then
  echo "SCOPE is required (for example example.com or lab://webapi-5-fixture)" >&2
  exit 1
fi

case "$TARGETS" in
  /*) ;;
  *) TARGETS="$ROOT/$TARGETS" ;;
esac
case "$OUT" in
  /*) ;;
  *) OUT="$ROOT/$OUT" ;;
esac

if ! command -v "$DAGGER" >/dev/null 2>&1; then
  echo "dagger not found; set DAGGER=/path/to/dagger" >&2
  exit 1
fi
if [ ! -s "$TARGETS" ]; then
  echo "targets file is missing or empty: $TARGETS" >&2
  echo "create it outside version control, or set TARGETS=/path/to/targets.txt" >&2
  exit 1
fi

# Keep stale files out of the exported artifact directory.
case "$OUT" in
  "$ROOT"/artifacts/*) rm -rf "$OUT" ;;
  *)
    echo "refusing to clean output outside $ROOT/artifacts: $OUT" >&2
    exit 1
    ;;
esac
mkdir -p "$(dirname "$OUT")"

cd "$ROOT"
if [ "${LOCAL_FIXTURE:-0}" = "1" ]; then
  "$DAGGER" call -m ci artifacts \
    --scope "$SCOPE" \
    --commit "$COMMIT" \
    --targets "$TARGETS" \
    --local-fixture \
    export --path "$OUT"
else
  "$DAGGER" call -m ci artifacts \
    --scope "$SCOPE" \
    --commit "$COMMIT" \
    --targets "$TARGETS" \
    export --path "$OUT"
fi

"$DAGGER" call -m ci check --artifacts "$OUT"

if command -v jq >/dev/null 2>&1; then
  jq '{scope, commit, tools, exit_codes, counts: (.outputs | map_values(.bytes))}' \
    "$OUT/run-manifest.json"
fi
