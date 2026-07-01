#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Deploy the full stack: networks, volumes, pull, start, health-wait.
# ------------------------------------------------------------------------------
#  Script  : setup/deploy.sh
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
  log_info "Deploying GeoServer HA Platform (${DOMAIN})..."
  [[ -f "${REPO_ROOT}/.env" ]] || log_warn "No .env present - copy .env.example to .env before production use"
  "${REPO_ROOT}/scripts/setup/create-network.sh"
  "${REPO_ROOT}/scripts/setup/create-volumes.sh"
  log_info "Pulling images..."
  compose pull
  log_info "Starting the stack..."
  compose up -d
  log_info "Waiting for services to report healthy..."
  "${REPO_ROOT}/scripts/health/check-postgres.sh"  || log_warn "PostgreSQL not healthy yet"
  "${REPO_ROOT}/scripts/health/check-geoserver.sh" || log_warn "GeoServer not healthy yet"
  log_ok "Deployment complete. GeoServer: https://${DOMAIN}/geoserver"
}
main "$@"
