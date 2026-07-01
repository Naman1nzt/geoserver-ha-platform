#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Mark every repository script as executable.
# ------------------------------------------------------------------------------
#  Script  : setup/setup-permissions.sh
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
  log_info "Marking all repository scripts as executable..."
  local count=0
  while IFS= read -r -d '' f; do
    chmod +x "$f"; count=$((count + 1))
  done < <(find "${REPO_ROOT}/scripts" -type f -name '*.sh' -print0)
  log_ok "made ${count} scripts executable"
}
main "$@"
