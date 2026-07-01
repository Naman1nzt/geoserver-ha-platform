#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Check primary + replica accept connections and report replication lag.
# ------------------------------------------------------------------------------
#  Script  : health/check-postgres.sh
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
  local rc=0
  for node in "$PG_PRIMARY" "$PG_REPLICA"; do
    if ! container_up "$node"; then log_error "${node}: not running"; rc=1; continue; fi
    if docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$node" \
         pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; then
      log_ok "${node}: accepting connections"
    else
      log_error "${node}: pg_isready failed"; rc=1
    fi
  done

  if container_up "$PG_PRIMARY"; then
    local lag
    lag="$(docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$PG_PRIMARY" \
      psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc \
      "SELECT COALESCE(MAX(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)), 0) FROM pg_stat_replication;" \
      2>/dev/null || echo NA)"
    log_info "Replication lag: ${lag} byte(s)"
  fi
  return "$rc"
}
main "$@"
