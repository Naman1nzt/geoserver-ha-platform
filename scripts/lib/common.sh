#!/usr/bin/env bash
# ==============================================================================
#  GeoServer HA Platform  -  Production Reference Implementation
#  Shared functions sourced by all scripts.
# ------------------------------------------------------------------------------
#  Script  : lib/common.sh
#  Author  : Naman1nzt
#  Repo    : https://github.com/Naman1nzt/geoserver-ha-platform
#  License : MIT
#  Note    : Client-neutral reference. All names/domains are fictional
#            (example.local) and safe for public GitHub.
# ==============================================================================

# ------------------------------------------------------------------------------
#  Shared library sourced by every operational script in this repository.
#  Provides: path resolution, colourised logging, guards, a docker-compose
#  wrapper, .env loading and the canonical (fictional) container names.
# ------------------------------------------------------------------------------

# --- Resolve important paths --------------------------------------------------
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${LIB_DIR}/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/docker-compose.yml"
BACKUP_DIR="${BACKUP_DIR:-${REPO_ROOT}/backups}"

# --- Colours / logging --------------------------------------------------------
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_INFO=$'\033[0;36m'; C_OK=$'\033[0;32m'
  C_WARN=$'\033[0;33m'; C_ERR=$'\033[0;31m'
else
  C_RESET=""; C_INFO=""; C_OK=""; C_WARN=""; C_ERR=""
fi

_ts() { date '+%Y-%m-%d %H:%M:%S'; }
log_info()  { printf '%s[%s] [INFO ]%s %s\n' "$C_INFO" "$(_ts)" "$C_RESET" "$*"; }
log_ok()    { printf '%s[%s] [ OK  ]%s %s\n' "$C_OK"   "$(_ts)" "$C_RESET" "$*"; }
log_warn()  { printf '%s[%s] [WARN ]%s %s\n' "$C_WARN" "$(_ts)" "$C_RESET" "$*" >&2; }
log_error() { printf '%s[%s] [ERROR]%s %s\n' "$C_ERR"  "$(_ts)" "$C_RESET" "$*" >&2; }
die()       { log_error "$*"; exit 1; }

# --- Guards / helpers ---------------------------------------------------------
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }

confirm() {
  # confirm "message" -> 0 if the user accepts. Set FORCE=1 to auto-approve.
  [[ "${FORCE:-0}" == "1" ]] && return 0
  local reply
  read -r -p "${C_WARN}$1 [y/N]: ${C_RESET}" reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

container_up() {
  [[ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null || echo false)" == "true" ]]
}

# --- Environment --------------------------------------------------------------
load_env() {
  if [[ -f "${REPO_ROOT}/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/.env"
    set +a
  else
    log_warn ".env not found - using built-in fictional defaults"
  fi
  : "${POSTGRES_USER:=gis_admin}"
  : "${POSTGRES_PASSWORD:=change_me_in_env}"
  : "${POSTGRES_DB:=gisdb}"
  : "${PATRONI_SCOPE:=geo-ha}"
  : "${DOMAIN:=gis.example.local}"
  : "${BACKUP_RETENTION_DAYS:=14}"
}

# --- Docker Compose wrapper ---------------------------------------------------
require_cmd docker
if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose -f "$COMPOSE_FILE")
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE=(docker-compose -f "$COMPOSE_FILE")
else
  die "Neither 'docker compose' nor 'docker-compose' is available"
fi
compose() { "${COMPOSE[@]}" "$@"; }

load_env

# --- Canonical (fictional) container names; override any in .env --------------
GEO1="${GEO1:-geo-primary}"
GEO2="${GEO2:-geo-secondary}"
PG_PRIMARY="${PG_PRIMARY:-postgres-primary}"
PG_REPLICA="${PG_REPLICA:-postgres-replica}"
PATRONI1="${PATRONI1:-patroni01}"
PATRONI2="${PATRONI2:-patroni02}"
HAPROXY="${HAPROXY:-haproxy}"
NGINX="${NGINX:-nginx}"
PROMETHEUS="${PROMETHEUS:-prometheus}"
GRAFANA="${GRAFANA:-grafana}"
ALERTMANAGER="${ALERTMANAGER:-alertmanager}"
PGADMIN="${PGADMIN:-pgadmin}"
# shellcheck disable=SC2034  # exported for use by scripts that source this library
GEO_NODES=("$GEO1" "$GEO2")
