#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Trigger an unplanned Patroni failover (promote a replica).
# ------------------------------------------------------------------------------
#  Script  : failover/manual-failover.sh
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
  log_warn "Manual FAILOVER promotes a replica and demotes the current leader."
  confirm "Trigger a Patroni failover for scope '${PATRONI_SCOPE}'?" || die "Aborted."
  docker exec -it "$PATRONI1" patronictl -c /etc/patroni.yml failover "$PATRONI_SCOPE" \
    || die "patronictl failover failed"
  log_ok "Failover requested. Verifying new topology..."
  "${REPO_ROOT}/scripts/health/check-patroni.sh" || true
}
main "$@"
