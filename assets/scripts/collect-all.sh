#!/usr/bin/env bash
# .compliance/scripts/collect-all.sh
# Runs all evidence collection scripts in this directory
# Usage:    bash collect-all.sh [-v]
set -uo pipefail

# ── Options ────────────────────────────────────────────
VERBOSE=false
PASSTHROUGH_ARGS=()

while getopts "v" opt; do
  case $opt in
    v) VERBOSE=true; PASSTHROUGH_ARGS+=("-v") ;;
    *) echo "Usage: $0 [-v]"; exit 1 ;;
  esac
done

log() {
  if $VERBOSE; then
    echo "[$(date -u '+%H:%M:%S')] $*" >&2
  fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SECRETS_FILE="$REPO_ROOT/.compliance/secrets.env"

# Load secrets from .compliance/secrets.env if it exists (for local testing)
if [ -f "$SECRETS_FILE" ]; then
  echo "Loading secrets from .compliance/secrets.env"
  log "Sourcing ${SECRETS_FILE}"
  set -a
  # shellcheck source=/dev/null
  source "$SECRETS_FILE"
  set +a
fi

echo "Compliance Evidence Collection — $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "================================================"

failed=0
for script in "${SCRIPT_DIR}"/*.sh; do
  [ "$(basename "$script")" = "collect-all.sh" ] && continue
  tool=$(basename "$script" .sh)
  echo ""
  echo "--- Collecting: ${tool} ---"
  log "Running: bash ${script} ${PASSTHROUGH_ARGS[*]:-}"
  if bash "$script" "${PASSTHROUGH_ARGS[@]+"${PASSTHROUGH_ARGS[@]}"}"; then
    echo "OK: ${tool}"
  else
    echo "FAILED: ${tool} (continuing...)"
    failed=$((failed + 1))
  fi
done

echo ""
echo "================================================"
log "COMPLETE: ${failed} failure(s)"
echo "Collection complete. ${failed} failure(s)."
[ "$failed" -eq 0 ] || exit 1
