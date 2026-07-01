#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Read the HAProxy stats endpoint and report backend UP/DOWN counts.
# ------------------------------------------------------------------------------
#  Script  : health/check-haproxy.sh
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
  container_up "$HAPROXY" || die "${HAPROXY} not running"
  local out
  out="$(docker exec "$HAPROXY" sh -c \
    'curl -s "http://localhost:8404/stats;csv" 2>/dev/null || wget -qO- "http://localhost:8404/stats;csv" 2>/dev/null || echo ""')"
  if [[ -z "$out" ]]; then
    log_warn "Could not read HAProxy stats (enable stats on :8404 in haproxy.cfg)"; return 1
  fi
  local up down
  up="$(echo "$out"   | awk -F, '$18=="UP"{c++}   END{print c+0}')"
  down="$(echo "$out" | awk -F, '$18=="DOWN"{c++} END{print c+0}')"
  log_info "HAProxy backends - UP: ${up}, DOWN: ${down}"
  if [[ "$down" == "0" ]]; then
    log_ok "All HAProxy backends healthy."; return 0
  fi
  log_error "${down} backend(s) DOWN."; return 1
}
main "$@"
