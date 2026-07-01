#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Timestamped logical backup of PostgreSQL plus the shared GeoServer data dir.
# ------------------------------------------------------------------------------
#  Script  : backup/backup.sh
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
  mkdir -p "$BACKUP_DIR"
  local stamp; stamp="$(date '+%Y%m%d-%H%M%S')"
  local db_file="${BACKUP_DIR}/pg-${POSTGRES_DB}-${stamp}.sql.gz"
  local geo_file="${BACKUP_DIR}/geoserver-data-${stamp}.tar.gz"

  log_info "Backing up database '${POSTGRES_DB}' from ${PG_PRIMARY}..."
  container_up "$PG_PRIMARY" || die "Container ${PG_PRIMARY} is not running"
  docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$PG_PRIMARY" \
    pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=plain | gzip -9 > "$db_file"
  log_ok "database backup -> ${db_file} ($(du -h "$db_file" | cut -f1))"

  log_info "Backing up shared GeoServer data directory..."
  if docker run --rm -v shared-geoserver-data:/data:ro -v "${BACKUP_DIR}:/backup" \
       alpine tar czf "/backup/$(basename "$geo_file")" -C /data . 2>/dev/null; then
    log_ok "geoserver backup -> ${geo_file}"
  else
    log_warn "GeoServer data volume backup skipped (volume not found)"
  fi
  log_ok "Backup complete."
}
main "$@"
