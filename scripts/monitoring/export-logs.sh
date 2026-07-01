#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Bundle logs from every running service into a single tarball.
# ------------------------------------------------------------------------------
#  Script  : monitoring/export-logs.sh
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
  local out_dir="${REPO_ROOT}/logs"; mkdir -p "$out_dir"
  local stamp; stamp="$(date '+%Y%m%d-%H%M%S')"
  local bundle="${out_dir}/logs-${stamp}.tar.gz"
  local tmp; tmp="$(mktemp -d)"
  log_info "Exporting logs from all running services..."
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    docker logs "$name" > "${tmp}/${name}.log" 2>&1 || true
    log_info "  captured ${name}"
  done < <(compose ps --format '{{.Name}}' 2>/dev/null || docker ps --format '{{.Names}}')
  tar czf "$bundle" -C "$tmp" . && rm -rf "$tmp"
  log_ok "Log bundle -> ${bundle}"
}
main "$@"
