#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Check that GeoServer node(s) answer on the web endpoint.
# ------------------------------------------------------------------------------
#  Script  : health/check-geoserver.sh
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

check_one() {
  local node="$1"
  container_up "$node" || { log_error "${node}: not running"; return 1; }
  local code
  code="$(docker exec "$node" sh -c \
    'curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/geoserver/web/ 2>/dev/null || echo 000')"
  if [[ "$code" == "200" || "$code" == "302" ]]; then
    log_ok "${node}: GeoServer healthy (HTTP ${code})"; return 0
  fi
  log_error "${node}: GeoServer unhealthy (HTTP ${code})"; return 1
}

main() {
  local rc=0
  if [[ $# -ge 1 ]]; then
    check_one "$1" || rc=1
  else
    for n in "${GEO_NODES[@]}"; do check_one "$n" || rc=1; done
  fi
  return "$rc"
}
main "$@"
