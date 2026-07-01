#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Restore a chosen (or latest) database backup into the primary node.
# ------------------------------------------------------------------------------
#  Script  : restore/restore.sh
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

list_backups() { ls -1t "${BACKUP_DIR}"/pg-*.sql.gz 2>/dev/null; }

main() {
  local file="${1:-}"
  if [[ -z "$file" ]]; then
    log_info "Available database backups:"
    list_backups || die "No backups found in ${BACKUP_DIR}"
    file="$(list_backups | head -n1)"
    log_warn "No file given - defaulting to latest: $(basename "$file")"
  fi
  [[ -f "$file" ]] || die "Backup file not found: $file"

  log_warn "This will OVERWRITE database '${POSTGRES_DB}' on the primary node."
  confirm "Restore ${file} into ${POSTGRES_DB}?" || die "Aborted."
  container_up "$PG_PRIMARY" || die "Primary container not running"

  log_info "Restoring..."
  zcat "$file" | docker exec -i -e PGPASSWORD="$POSTGRES_PASSWORD" "$PG_PRIMARY" \
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
  log_ok "Restore complete. Replica(s) will catch up via WAL replication."
}
main "$@"
