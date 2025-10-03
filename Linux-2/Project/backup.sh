#!/usr/bin/env bash
# backup.sh - incremental backup using rsync + optional tar snapshot, rotation and verification
#
# Usage:
#   ./backup.sh --source /path/to/src --dest /path/to/backups [OPTIONS]
#
# Options:
#   --source DIR            Directory to back up (required)
#   --dest DIR              Backup destination (required)
#   --name NAME             Short name for this backup job (default: hostname)
#   --snapshots N           Number of snapshots to keep (default: 7)
#   --compress              Create a timestamped tar.gz snapshot after rsync
#   --remote "user@host:/path"  Use rsync over SSH to remote target (overrides --dest if provided)
#   --ssh-key /path/to/key  SSH key for remote rsync (optional)
#   --exclude-file FILE     Path to rsync exclude-file (one pattern per line)
#   --verify                Verify rsync by comparing checksums after copy (may be slow)
#   --log FILE              Log file (default: ./backup.log)
#   --dry-run               Run but do not make changes (rsync --dry-run)
#   -h|--help               Show help
#
# Exit codes:
# 0 = success
# 1 = usage / invalid args
# 2 = source not found
# 3 = dest not found / cannot create dest
# 4 = rsync failed
# 5 = verification failed
# 6 = rotation failed
#
set -euo pipefail
IFS=$'\n\t'

# Defaults
SNAPSHOTS=7
COMPRESS=0
VERIFY=0
DRYRUN=0
LOG="./backup.log"
NAME="$(hostname -s)"
SSH_KEY=""
EXCLUDE_FILE=""
REMOTE=""
RSYNC_OPTS="-aHAX --delete --numeric-ids --partial --progress"
TSTAMP="$(date +%Y-%m-%d_%H%M%S)"

usage() {
  sed -n '1,200p' <<USAGE
Usage: $0 --source DIR --dest DIR [options]

Required:
  --source DIR      Local path to back up
  --dest DIR        Local directory to store backups (or ignored if --remote supplied)

Optional:
  --name NAME       Job name (default: ${NAME})
  --snapshots N     Keep N snapshots (default: ${SNAPSHOTS})
  --compress        Create tar.gz snapshot after rsync
  --remote USER@HOST:/path    Send backups to remote using rsync over SSH
  --ssh-key PATH    Private key for SSH
  --exclude-file FILE  Rsync exclude patterns
  --verify          Run checksum verification after copy
  --log FILE        Log file (default: ${LOG})
  --dry-run         Do not change anything (passes --dry-run to rsync)
  -h|--help
Examples:
  # Local incremental backup:
  $0 --source /etc --dest /backups/etc --name etc --snapshots 14 --compress

  # Remote incremental backup:
  $0 --source /var/www --remote backup@backup.example.com:/data/backups/www --ssh-key ~/.ssh/backup_rsa

USAGE
}

log() { printf '%s %s\n' "$(date +'%Y-%m-%dT%H:%M:%S')" "$*" >>"$LOG"; }

# parse args
if [ $# -eq 0 ]; then usage; exit 1; fi
while [ $# -gt 0 ]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2;;
    --dest) DEST="$2"; shift 2;;
    --name) NAME="$2"; shift 2;;
    --snapshots) SNAPSHOTS="$2"; shift 2;;
    --compress) COMPRESS=1; shift;;
    --remote) REMOTE="$2"; shift 2;;
    --ssh-key) SSH_KEY="$2"; shift 2;;
    --exclude-file) EXCLUDE_FILE="$2"; shift 2;;
    --verify) VERIFY=1; shift;;
    --log) LOG="$2"; shift 2;;
    --dry-run) DRYRUN=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

: "${SOURCE:?--source is required}"

if [ -z "${REMOTE:-}" ]; then
  : "${DEST:?--dest is required (or use --remote)}"
fi

# sanity checks
if [ ! -d "$SOURCE" ]; then
  echo "Source not found: $SOURCE" >&2
  exit 2
fi

# build effective destination path
if [ -n "$REMOTE" ]; then
  # remote mode: dest root handled by rsync target
  BACKUP_ROOT="${REMOTE%/}/${NAME}"
  # no local rotation applied in remote mode (we'll place snapshots under remote path with timestamp)
else
  mkdir -p "$DEST" 2>/dev/null || { echo "Cannot create dest: $DEST" >&2; exit 3; }
  BACKUP_ROOT="${DEST%/}/${NAME}"
  mkdir -p "$BACKUP_ROOT" 2>/dev/null || { echo "Cannot create backup root: $BACKUP_ROOT" >&2; exit 3; }
fi

# create log file
touch "$LOG" || true
log "Starting backup job: $NAME source=$SOURCE dest=${REMOTE:-$BACKUP_ROOT} compress=$COMPRESS verify=$VERIFY snapshots=$SNAPSHOTS"

# rsync target directory name: latest is a symlink to timestamped dir for easy point-in-time
TS_DIR="${TSTAMP}"
if [ -n "$REMOTE" ]; then
  RSYNC_TARGET="${BACKUP_ROOT}/${TS_DIR}/"
else
  RSYNC_TARGET="${BACKUP_ROOT}/${TS_DIR}/"
  mkdir -p "$RSYNC_TARGET"
fi

# build ssh option if remote
SSH_ARG=""
if [ -n "$REMOTE" ]; then
  if [ -n "$SSH_KEY" ]; then
    SSH_ARG="-e 'ssh -i ${SSH_KEY} -o StrictHostKeyChecking=accept-new'"
  else
    SSH_ARG="-e 'ssh -o StrictHostKeyChecking=accept-new'"
  fi
fi

# compose rsync command
RSYNC_CMD=(rsync)
if [ "$DRYRUN" -eq 1 ]; then RSYNC_CMD+=(--dry-run); fi
# append options and exclude file if present
# shellcheck disable=SC2206
RSYNC_CMD+=($RSYNC_OPTS)
if [ -n "$EXCLUDE_FILE" ]; then RSYNC_CMD+=(--exclude-from="$EXCLUDE_FILE"); fi
# preserve ACL/xattrs if possible
# source dir trailing slash: copy contents
RSYNC_CMD+=("$SOURCE"/ "$RSYNC_TARGET")

# run rsync (possibly wrapped by ssh - handled via -e)
log "Running rsync: ${RSYNC_CMD[*]}"
# If remote mode and SSH_ARG present, construct whole command string
if [ -n "$REMOTE" ]; then
  # Use eval to allow -e 'ssh ...' composed above
  eval "${RSYNC_CMD[*]/rsync/rsync $SSH_ARG}"
  RSYNC_EXIT=$?
else
  "${RSYNC_CMD[@]}"
  RSYNC_EXIT=$?
fi

if [ $RSYNC_EXIT -ne 0 ]; then
  log "ERROR: rsync failed with code $RSYNC_EXIT"
  echo "rsync failed (code $RSYNC_EXIT)" >&2
  exit 4
fi
log "rsync finished successfully"

# update 'latest' symlink for local dest (remote mode: attempt to create symlink via ssh if needed)
if [ -z "$REMOTE" ]; then
  ln -sfn "$TS_DIR" "${BACKUP_ROOT}/latest"
  log "Updated latest -> ${TS_DIR}"
else
  # try to create a remote 'latest' symlink (best-effort)
  if command -v ssh >/dev/null 2>&1; then
    REMOTE_HOST="${REMOTE%%:*}"
    REMOTE_PATH="${REMOTE#*:}"
    # remote symlink creation (best-effort, silent)
    if [ -n "$SSH_KEY" ]; then
      ssh -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$REMOTE_HOST" "ln -sfn '${REMOTE_PATH%/}/${NAME}/${TS_DIR}' '${REMOTE_PATH%/}/${NAME}/latest'" || true
    else
      ssh -o StrictHostKeyChecking=accept-new "$REMOTE_HOST" "ln -sfn '${REMOTE_PATH%/}/${NAME}/${TS_DIR}' '${REMOTE_PATH%/}/${NAME}/latest'" || true
    fi
  fi
fi

# optional compress snapshot: tar.gz the timestamped dir (local only)
if [ "$COMPRESS" -eq 1 ] && [ -z "$REMOTE" ]; then
  SNAPSHOT_FILE="${BACKUP_ROOT}/${NAME}-${TS_DIR}.tar.gz"
  log "Creating tar.gz snapshot: $SNAPSHOT_FILE"
  tar -C "$BACKUP_ROOT" -czf "$SNAPSHOT_FILE" "$TS_DIR"
  if [ $? -ne 0 ]; then
    log "ERROR: tar failed"
  else
    log "Snapshot created: $SNAPSHOT_FILE"
  fi
fi

# optional verify: compare checksums (local only; remote verification is expensive)
if [ "$VERIFY" -eq 1 ]; then
  log "Starting verification (checksums)"
  if [ -n "$REMOTE" ]; then
    log "Skipping full verification in remote mode (not implemented)"
  else
    # generate checksum lists and compare
    pushd "$SOURCE" >/dev/null
    find . -type f -print0 | xargs -0 sha256sum | sort -k2 > "$BACKUP_ROOT/checksums-src-${TS_DIR}.txt"
    popd >/dev/null
    pushd "$RSYNC_TARGET" >/dev/null
    find . -type f -print0 | xargs -0 sha256sum | sort -k2 > "$BACKUP_ROOT/checksums-dst-${TS_DIR}.txt"
    popd >/dev/null
    # compare
    if ! diff -u "$BACKUP_ROOT/checksums-src-${TS_DIR}.txt" "$BACKUP_ROOT/checksums-dst-${TS_DIR}.txt" >/dev/null; then
      log "ERROR: verification mismatch"
      echo "Verification failed: checksum mismatch" >&2
      exit 5
    fi
    log "Verification OK"
  fi
fi

# rotation: keep only N most recent timestamped directories (local only)
if [ -z "$REMOTE" ]; then
  pushd "$BACKUP_ROOT" >/dev/null
  # list timestamp dirs (YYYY-...)
  mapfile -t DIRS < <(find -1d [0-9]*_* 2>/dev/null | sort -r)
  if [ "${#DIRS[@]}" -gt "$SNAPSHOTS" ]; then
    for idx in "${!DIRS[@]}"; do
      if [ "$idx" -ge "$SNAPSHOTS" ]; then
        OLD="${DIRS[$idx]}"
        rm -rf -- "$OLD"
        log "Rotated out old snapshot: $OLD"
      fi
    done
  fi
  popd >/dev/null || true
fi

log "Backup job completed successfully"
exit 0

#-----------------------------------------------------------------------------#
# Notes & usage:
# Incremental flow: rsync copies changed files to a timestamped folder. --delete ensures exact mirror.
# Retention: Keeps N timestamped directories; older ones deleted.
# Compression: --compress creates a .tar.gz of the just-created snapshot.
# Remote: Use --remote user@host:/path and --ssh-key to rsync to a remote server.
# Verification: --verify computes SHA256 checksums and compares (slow for large datasets).
# Logging: Appends to --log file.
# Dry-run: Use --dry-run to test.

# Crontab example (daily at 02:30):
# >> 30 2 * * * /usr/local/bin/backup.sh --source /var/www --dest /backups/www --name www --snapshots 14 --compress --log /var/log/backup-www.log

# If you prefer systemd timer, create a service and timer — tell me and I’ll provide the unit files.