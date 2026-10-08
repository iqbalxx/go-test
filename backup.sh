#!/usr/bin/env bash
set -euo pipefail

# Configuration
DB_NAME="${DB_NAME:-mydb}"
DB_USER="${DB_USER:-postgres}"
DB_HOST="${DB_HOST:-localhost}"
BACKUP_DIR="${BACKUP_DIR:-/backups/postgres}"
KEEP_COUNT=7

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.dump"

mkdir -p "$BACKUP_DIR"

# Dump the database with pg_dump (-Fc for compressed custom format)
if ! pg_dump -Fc -h "$DB_HOST" -U "$DB_USER" "$DB_NAME" -f "$BACKUP_FILE"; then
    echo "ERROR: pg_dump failed" >&2
    exit 1
fi

# Verify the backup file is not empty
if [ ! -s "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file is empty" >&2
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Keep only the 7 newest backups, remove older ones
ls -1t "${BACKUP_DIR}/${DB_NAME}_"*.dump | tail -n +$((KEEP_COUNT + 1)) | xargs -r rm -f

echo "SUCCESS: Backup created at ${BACKUP_FILE}"
