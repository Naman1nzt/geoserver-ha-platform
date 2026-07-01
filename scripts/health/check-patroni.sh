#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Print the Patroni topology and assert exactly one leader exists.
# ------------------------------------------------------------------------------
#  Script  : health/check-patroni.sh
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
  container_up "$PATRONI1" || die "${PATRONI1} not running"
  log_info "Patroni cluster state (scope: ${PATRONI_SCOPE}):"
  docker exec "$PATRONI1" patronictl -c /etc/patroni.yml list "$PATRONI_SCOPE" \
    || die "patronictl list failed"
  local leaders
  leaders="$(docker exec "$PATRONI1" patronictl -c /etc/patroni.yml list "$PATRONI_SCOPE" 2>/dev/null \
    | grep -ci 'leader' || true)"
  if [[ "${leaders:-0}" == "1" ]]; then
    log_ok "Exactly one leader present."; return 0
  fi
  log_error "Expected exactly 1 leader, found ${leaders:-0}."; return 1
}
main "$@"
