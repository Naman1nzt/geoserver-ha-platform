#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Convenience wrapper to follow logs for a single service.
# ------------------------------------------------------------------------------
#  Script  : utilities/logs.sh
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
  local svc="${1:-}"
  local lines="${2:-200}"
  if [[ -z "$svc" ]]; then
    log_info "Usage: logs.sh <service> [lines] - follows logs. Available services:"
    compose ps --services 2>/dev/null || true
    exit 0
  fi
  log_info "Tailing last ${lines} lines of '${svc}' (Ctrl-C to stop)..."
  compose logs -f --tail "$lines" "$svc"
}
main "$@"
