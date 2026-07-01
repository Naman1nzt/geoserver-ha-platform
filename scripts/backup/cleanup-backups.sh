#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Apply a retention policy, deleting backups older than N days.
# ------------------------------------------------------------------------------
#  Script  : backup/cleanup-backups.sh
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
  local days="${1:-$BACKUP_RETENTION_DAYS}"
  [[ -d "$BACKUP_DIR" ]] || die "Backup dir not found: $BACKUP_DIR"
  log_info "Removing backups older than ${days} days from ${BACKUP_DIR}..."
  local removed=0
  while IFS= read -r -d '' f; do
    log_info "  deleting $(basename "$f")"
    rm -f "$f"; removed=$((removed + 1))
  done < <(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name '*.sql.gz' -o -name '*.tar.gz' \) -mtime +"$days" -print0)
  log_ok "Removed ${removed} old backup(s)."
}
main "$@"
