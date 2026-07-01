#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Create the named Docker volumes for state that must survive restarts.
# ------------------------------------------------------------------------------
#  Script  : setup/create-volumes.sh
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
  log_info "Ensuring Docker volumes exist..."
  local vols=(
    "shared-geoserver-data" "pgdata-primary" "pgdata-replica"
    "etcd01-data" "etcd02-data" "etcd03-data"
    "prometheus-data" "grafana-data" "pgadmin-data"
  )
  for v in "${vols[@]}"; do
    if docker volume inspect "$v" >/dev/null 2>&1; then
      log_ok "volume '$v' already exists"
    else
      docker volume create "$v" >/dev/null
      log_ok "created volume '$v'"
    fi
  done
}
main "$@"
