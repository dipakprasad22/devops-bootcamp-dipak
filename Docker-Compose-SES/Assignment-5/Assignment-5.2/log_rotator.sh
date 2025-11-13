#!/bin/bash

# Execute this script like ./log_rotator.sh 
# All the arguments are set in .env-sample file. The Script will read from there.

# Load variables from .env-sample if it exists
if [ -f .env-sample ]; then
  export $(grep -v '^#' .env-sample | xargs)
fi

# Use env variables or defaults
LOG_DIR=${LOG_DIR:-logs}
ARCHIVE_DIR=${ARCHIVE_DIR:-archive}
INTERVAL_MINUTES=${INTERVAL_MINUTES:-60}
RETENTION_DAYS=${RETENTION_DAYS:-7}
MODE=${MODE:-loop}

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
[ ! -d "$ARCHIVE_DIR" ] && mkdir -p "$ARCHIVE_DIR"

rotate_logs() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    DEST_DIR="$ARCHIVE_DIR/$TIMESTAMP"
    mkdir -p "$DEST_DIR"

    if [ "$(ls -A $LOG_DIR)" ]; then
        mv "$LOG_DIR"/*.log "$DEST_DIR"/
        echo "[$(date)] Logs rotated to $DEST_DIR"
    else
        echo "[$(date)] No logs to rotate."
    fi

    find "$ARCHIVE_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;
}

if [ "$MODE" == "once" ]; then
    rotate_logs
    exit 0
else
    while true; do
        rotate_logs
        sleep "${INTERVAL_MINUTES}m"
    done
fi