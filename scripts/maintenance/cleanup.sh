#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Reclaim disk from dangling Docker resources (named volumes preserved).
# ------------------------------------------------------------------------------
#  Script  : maintenance/cleanup.sh
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
  log_info "Reclaiming space from dangling Docker resources..."
  confirm "Prune dangling images, stopped containers and build cache?" || die "Aborted."
  docker container prune -f >/dev/null && log_ok "removed stopped containers"
  docker image prune -f     >/dev/null && log_ok "removed dangling images"
  docker builder prune -f   >/dev/null 2>&1 || true
  log_ok "Cleanup complete (named volumes and networks were preserved)."
}
main "$@"
