#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Perform a planned, zero-data-loss switchover of the primary role.
# ------------------------------------------------------------------------------
#  Script  : failover/switchover.sh
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
  log_info "Planned SWITCHOVER (controlled role swap, no data loss)."
  confirm "Perform a planned switchover for scope '${PATRONI_SCOPE}'?" || die "Aborted."
  docker exec -it "$PATRONI1" patronictl -c /etc/patroni.yml switchover "$PATRONI_SCOPE" \
    || die "patronictl switchover failed"
  log_ok "Switchover complete."
  "${REPO_ROOT}/scripts/health/check-patroni.sh" || true
}
main "$@"
