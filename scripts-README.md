# Operational Scripts

Production-grade helper scripts for the **GeoServer HA Platform**.
Author: **Naman1nzt**  ·  License: MIT  ·  All names are fictional (`example.local`).

Every script sources `scripts/lib/common.sh` for consistent logging, `.env`
loading, a `docker compose` wrapper and the canonical container names.

## First run
```bash
cp .env.example .env          # then edit the values
./scripts/setup/setup-permissions.sh
./scripts/setup/init-cluster.sh
```

## Layout
| Folder | Scripts |
|--------|---------|
| `setup/` | `init-cluster.sh`, `deploy.sh`, `create-network.sh`, `create-volumes.sh`, `setup-permissions.sh` |
| `backup/` | `backup.sh`, `verify-backup.sh`, `cleanup-backups.sh` |
| `restore/` | `restore.sh` |
| `failover/` | `manual-failover.sh`, `switchover.sh`, `promote-replica.sh` |
| `maintenance/` | `rolling-update.sh`, `update-geoserver.sh`, `cleanup.sh`, `rotate-logs.sh` |
| `health/` | `check-geoserver.sh`, `check-postgres.sh`, `check-patroni.sh`, `check-haproxy.sh` |
| `monitoring/` | `collect-metrics.sh`, `export-logs.sh` |
| `utilities/` | `docker-status.sh`, `restart-services.sh`, `logs.sh` |
| `lib/` | `common.sh` (shared library) |

## Conventions
- `set -euo pipefail` in every script.
- Destructive actions prompt for confirmation; set `FORCE=1` to skip prompts in automation.
- Container names come from `.env` (fall back to fictional defaults) so they can be remapped without editing scripts.
