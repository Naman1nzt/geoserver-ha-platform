#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Write a point-in-time snapshot of container stats and Prometheus targets.
# ------------------------------------------------------------------------------
#  Script  : monitoring/collect-metrics.sh
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
  local out_dir="${REPO_ROOT}/logs/metrics"; mkdir -p "$out_dir"
  local stamp; stamp="$(date '+%Y%m%d-%H%M%S')"
  local file="${out_dir}/metrics-${stamp}.txt"
  log_info "Collecting a metrics snapshot..."
  {
    echo "# Snapshot ${stamp}"
    echo "## docker stats"
    docker stats --no-stream \
      --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}' 2>/dev/null || true
    echo
    echo "## prometheus up targets"
    docker exec "$PROMETHEUS" sh -c \
      'wget -qO- "http://localhost:9090/api/v1/query?query=up" 2>/dev/null' \
      || log_warn "Prometheus query failed"
  } > "$file"
  log_ok "Metrics snapshot -> ${file}"
}
main "$@"
