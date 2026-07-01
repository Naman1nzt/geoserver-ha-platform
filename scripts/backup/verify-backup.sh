#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Verify integrity of a database backup archive (defaults to the latest).
# ------------------------------------------------------------------------------
#  Script  : backup/verify-backup.sh
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

latest() {
  find "${BACKUP_DIR}" -maxdepth 1 -type f -name 'pg-*.sql.gz' -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn | head -n1 | cut -d' ' -f2-
}

main() {
  local file="${1:-$(latest)}"
  [[ -n "$file" && -f "$file" ]] || die "No backup file found to verify"
  log_info "Verifying archive integrity: ${file}"
  if gzip -t "$file"; then
    log_ok "gzip integrity OK"
  else
    die "Corrupt gzip archive"
  fi
  if zcat "$file" | head -n 50 | grep -q 'PostgreSQL database dump'; then
    log_ok "pg_dump header present"
  else
    log_warn "Could not find pg_dump header (archive may still be valid)"
  fi
  log_ok "Verification finished."
}
main "$@"
