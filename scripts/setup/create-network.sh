#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Create the Docker bridge networks used by the platform.
# ------------------------------------------------------------------------------
#  Script  : setup/create-network.sh
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
  log_info "Ensuring Docker networks exist..."
  local nets=("frontend-net" "backend-net" "monitoring-net")
  for net in "${nets[@]}"; do
    if docker network inspect "$net" >/dev/null 2>&1; then
      log_ok "network '$net' already exists"
    else
      docker network create --driver bridge "$net" >/dev/null
      log_ok "created network '$net'"
    fi
  done
}
main "$@"
