#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Recreate GeoServer nodes one at a time for a zero-downtime update.
# ------------------------------------------------------------------------------
#  Script  : maintenance/rolling-update.sh
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
  log_info "Rolling update of GeoServer nodes (zero downtime)..."
  compose pull "$GEO1" "$GEO2" || log_warn "pull returned non-zero (continuing)"
  for node in "${GEO_NODES[@]}"; do
    log_info "Recreating ${node}..."
    compose up -d --no-deps "$node"
    log_info "Waiting for ${node} to become healthy..."
    local tries=0
    until "${REPO_ROOT}/scripts/health/check-geoserver.sh" "$node" >/dev/null 2>&1; do
      tries=$((tries + 1))
      [[ $tries -ge 24 ]] && die "${node} did not become healthy in time"
      sleep 5
    done
    log_ok "${node} updated and healthy."
  done
  log_ok "Rolling update complete - no service interruption."
}
main "$@"
