#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Rotate exported log bundles, keeping the last N days.
# ------------------------------------------------------------------------------
#  Script  : maintenance/rotate-logs.sh
#  Author  : Naman1nzt
#  Repo    : https://github.com/Naman1nzt/geoserver-ha-platform
#  License : MIT
#  Note    : Client-neutral reference. All names/domains are fictional
#            (example.local) and safe for public GitHub.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

main() {
  local keep="${1:-7}"
  local log_root="${REPO_ROOT}/logs"
  mkdir -p "$log_root"
  log_info "Rotating exported logs in ${log_root} (keeping ${keep} days)..."
  local removed=0
  while IFS= read -r -d '' f; do
    log_info "  rotated out $(basename "$f")"
    rm -f "$f"; removed=$((removed + 1))
  done < <(find "$log_root" -type f \( -name '*.log' -o -name 'logs-*.tar.gz' \) -mtime +"$keep" -print0)
  log_ok "Log rotation complete (${removed} file(s) removed)."
}
main "$@"
