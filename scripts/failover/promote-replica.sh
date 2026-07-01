#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Emergency promotion of a specific replica to leader.
# ------------------------------------------------------------------------------
#  Script  : failover/promote-replica.sh
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
  local node="${1:-$PATRONI2}"
  log_warn "EMERGENCY promotion of '${node}' (use only if the primary/DCS is unrecoverable)."
  confirm "Force-promote ${node}?" || die "Aborted."
  if docker exec "$node" sh -c 'command -v patronictl' >/dev/null 2>&1; then
    docker exec -it "$node" patronictl -c /etc/patroni.yml failover "$PATRONI_SCOPE" --candidate "$node" \
      || die "Promotion via patronictl failed"
  else
    die "patronictl not found in ${node}; inspect the cluster manually before promoting"
  fi
  log_ok "Promotion requested for ${node}."
}
main "$@"
