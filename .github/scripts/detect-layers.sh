#!/usr/bin/env bash
set -euo pipefail

EVENT_NAME="${1:-}"
BASE_SHA="${2:-}"
HEAD_SHA="${3:-}"
EXCLUDE_LAYERS="${4:-[]}"
MANUAL_LAYER="${5:-}"

: "${EVENT_NAME:?event_name is required}"
: "${HEAD_SHA:?head_sha is required}"

emit_output() {
  local key="$1"
  local value="$2"
  [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "${key}=${value}" >> "$GITHUB_OUTPUT"
  echo "[detect-layers] OUTPUT: ${key}=${value}"
}

if [[ -z "$BASE_SHA" ]] || [[ "$BASE_SHA" == "0000000000000000000000000000000000000000" ]] || ! git rev-parse --verify "$BASE_SHA" >/dev/null 2>&1; then
  echo "[detect-layers] BASE_SHA is invalid or missing. Attempting recovery..."
  if git rev-parse HEAD~1 >/dev/null 2>&1; then
    RESOLVED_BASE=$(git rev-parse HEAD~1)
  else
    RESOLVED_BASE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
  fi
else
  RESOLVED_BASE="$BASE_SHA"
fi

echo "[detect-layers] RESOLVED_BASE=${RESOLVED_BASE}"

filter_layers() {
  local json="$1"
  if [[ -z "$json" ]] || [[ "$json" == "null" ]]; then json="[]"; fi
  jq -c --argjson exclude "${EXCLUDE_LAYERS:-[]}" '
    map(select((. as $layer | ($exclude | index($layer))) | not))
  ' <<< "$json"
}

if [[ "$EVENT_NAME" == "workflow_dispatch" && -n "$MANUAL_LAYER" ]]; then
  CLEAN_LAYER="${MANUAL_LAYER#live/}"
  layers_json="[\"${CLEAN_LAYER}\"]"
else
  layers_json="$(bash .github/scripts/deploy.sh detect-layers "${RESOLVED_BASE}" "${HEAD_SHA}" || echo "[]")"
fi

# Sort shared layers first, then by node and VM name.
ORDERED_JSON=$(echo "${layers_json:-[]}" | jq -c 'if type == "array" then sort_by(
  if contains("_global") or contains("_shared") then 1
  else 2 end,
  .
) | unique else [] end')

filtered="$(filter_layers "$ORDERED_JSON")"

emit_output "layers" "$filtered"
emit_output "has_changes" "$([[ "$filtered" != "[]" ]] && echo "1" || echo "0")"
emit_output "base_sha" "$RESOLVED_BASE"
emit_output "head_sha" "$HEAD_SHA"
