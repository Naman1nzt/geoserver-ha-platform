#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Pin a new GeoServer image tag in .env and roll it out safely.
# ------------------------------------------------------------------------------
#  Script  : maintenance/update-geoserver.sh
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
  local version="${1:-}"
  [[ -n "$version" ]] || die "Usage: update-geoserver.sh <image-tag>   (e.g. 2.25.1)"
  log_info "Setting GeoServer image tag to '${version}' and rolling out..."
  if grep -q '^GEOSERVER_TAG=' "${REPO_ROOT}/.env" 2>/dev/null; then
    sed -i "s/^GEOSERVER_TAG=.*/GEOSERVER_TAG=${version}/" "${REPO_ROOT}/.env"
  else
    echo "GEOSERVER_TAG=${version}" >> "${REPO_ROOT}/.env"
  fi
  log_ok ".env updated (GEOSERVER_TAG=${version})"
  "${REPO_ROOT}/scripts/maintenance/rolling-update.sh"
}
main "$@"
