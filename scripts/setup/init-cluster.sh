#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  First-time cluster bootstrap: create infra, start, await a Patroni leader.
# ------------------------------------------------------------------------------
#  Script  : setup/init-cluster.sh
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
  log_info "Initialising a fresh GeoServer HA cluster..."
  confirm "This will create networks, volumes and start all services. Continue?" || die "Aborted."
  "${REPO_ROOT}/scripts/setup/create-network.sh"
  "${REPO_ROOT}/scripts/setup/create-volumes.sh"
  "${REPO_ROOT}/scripts/setup/deploy.sh"

  log_info "Waiting for a Patroni leader to be elected..."
  local tries=0
  until docker exec "$PATRONI1" patronictl -c /etc/patroni.yml list 2>/dev/null | grep -qi "leader"; do
    tries=$((tries + 1))
    [[ $tries -ge 30 ]] && die "No Patroni leader after 30 attempts"
    sleep 5
    log_info "  ...still waiting (${tries}/30)"
  done
  log_ok "Patroni leader elected."
  "${REPO_ROOT}/scripts/health/check-patroni.sh" || true
  log_ok "Cluster initialised."
}
main "$@"
