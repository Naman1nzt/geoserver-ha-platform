#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Restart one, several, or all compose services safely.
# ------------------------------------------------------------------------------
#  Script  : utilities/restart-services.sh
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
  if [[ $# -eq 0 ]]; then
    confirm "Restart ALL services?" || die "Aborted."
    compose restart
    log_ok "All services restarted."
  else
    for svc in "$@"; do
      log_info "Restarting ${svc}..."
      compose restart "$svc"
    done
    log_ok "Requested services restarted."
  fi
}
main "$@"
