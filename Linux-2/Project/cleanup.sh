#!/usr/bin/env bash
# cleanup.sh - safe automated disk cleanup and system maintenance
#
# Features:
#  - deletes files older than N days under given paths
#  - clears apt/yum caches (package manager) safely
#  - vacuums journalctl logs older than a time
#  - optional Docker cleanup (prune)
#  - reports disk usage before/after, logs actions
#
# Usage:
#   ./cleanup.sh [OPTIONS]
#
# Options:
#   --paths "/tmp,/var/tmp"     Comma-separated list of paths to prune (default: /tmp,/var/tmp)
#   --older-than DAYS           Delete files older than DAYS (default: 7)
#   --min-free-percent P        If free space percent is above P, skip deletion (default: 0)
#   --apt-clean                 Run apt-get clean (Debian/Ubuntu)
#   --yum-clean                 Run yum clean all (RHEL/CentOS)
#   --journal-vacuum 7d         Run journalctl --vacuum-time=7d (time string)
#   --docker-prune              Run docker system prune -af (requires docker and careful use)
#   --simulate                  Dry-run: show what WOULD be deleted
#   --log FILE                  Log file (default: ./cleanup.log)
#   -h, --help
#
# Exit codes:
# 0 = success (no fatal errors)
# 1 = invalid args
# 2 = nothing to do / path missing
# 3 = deletion failed (partial)
#
set -euo pipefail
IFS=$'\n\t'

# defaults
PATHS="/tmp,/var/tmp"
OLDER_THAN=7
MIN_FREE_PERCENT=0
APT_CLEAN=0
YUM_CLEAN=0
JOURNAL_VACUUM=""
DOCKER_PRUNE=0
SIMULATE=0
LOG="./cleanup.log"

usage() {
  sed -n '1,200p' <<USAGE
Usage: $0 [options]
Options:
  --paths "/tmp,/var/tmp"
  --older-than DAYS
  --min-free-percent P
  --apt-clean
  --yum-clean
  --journal-vacuum 7d
  --docker-prune
  --simulate
  --log FILE
  -h|--help
USAGE
}

log(){ printf '%s %s\n' "$(date +'%Y-%m-%dT%H:%M:%S')" "$*" >>"$LOG"; }

# parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --paths) PATHS="$2"; shift 2;;
    --older-than) OLDER_THAN="$2"; shift 2;;
    --min-free-percent) MIN_FREE_PERCENT="$2"; shift 2;;
    --apt-clean) APT_CLEAN=1; shift;;
    --yum-clean) YUM_CLEAN=1; shift;;
    --journal-vacuum) JOURNAL_VACUUM="$2"; shift 2;;
    --docker-prune) DOCKER_PRUNE=1; shift;;
    --simulate) SIMULATE=1; shift;;
    --log) LOG="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

touch "$LOG" || true
log "Starting cleanup. paths=$PATHS older_than=${OLDER_THAN}d min_free_percent=${MIN_FREE_PERCENT} apt_clean=$APT_CLEAN yum_clean=$YUM_CLEAN journal_vacuum=$JOURNAL_VACUUM docker_prune=$DOCKER_PRUNE simulate=$SIMULATE"

# helper: get free percent of root
get_free_percent() {
  df --output=pcent / | tail -n1 | tr -dc '0-9'
}

FREE_PCT=$(get_free_percent || echo 0)
log "Free percent on / = ${FREE_PCT}%"
if [ "${FREE_PCT:-0}" -gt 0 ] && [ "$FREE_PCT" -gt 100 ]; then
  FREE_PCT=0
fi

if [ "$MIN_FREE_PERCENT" -ne 0 ]; then
  if [ "$FREE_PCT" -ge "$MIN_FREE_PERCENT" ]; then
    log "Free space ${FREE_PCT}% >= ${MIN_FREE_PERCENT}% -> skipping cleanup."
    echo "Free space ${FREE_PCT}% >= ${MIN_FREE_PERCENT}% -> skipping cleanup."
    exit 0
  fi
fi

# delete old files under each path
IFS=',' read -r -a arr <<< "$PATHS"
DELETED_ANY=0
for p in "${arr[@]}"; do
  p_trimmed="$(echo "$p" | xargs)"
  if [ ! -d "$p_trimmed" ]; then
    log "Path not found or not a directory: $p_trimmed"
    continue
  fi
  log "Pruning files older than ${OLDER_THAN} days in $p_trimmed"
  if [ "$SIMULATE" -eq 1 ]; then
    log "[SIMULATE] find $p_trimmed -type f -mtime +$OLDER_THAN -print | head -n 200"
    find "$p_trimmed" -type f -mtime +"$OLDER_THAN" -print | head -n 200 >>"$LOG" || true
  else
    # find and delete safely (avoid swallowing spaces)
    mapfile -t OLD <- <(find "$p_trimmed" -type f -mtime +"$OLDER_THAN" -print)
    if [ "${#OLD[@]}" -eq 0 ]; then
      log "No files to delete under $p_trimmed"
      continue
    fi
    DELETED_ANY=1
    # delete in batches and log
    for file in "${OLD[@]}"; do
      if rm -f -- "$file"; then
        log "Deleted: $file"
      else
        log "Failed to delete: $file"
      fi
    done
  fi
done

# package manager cleanup
if [ "$APT_CLEAN" -eq 1 ]; then
  if command -v apt-get >/dev/null 2>&1; then
    log "Running apt-get clean"
    if [ "$SIMULATE" -eq 0 ]; then apt-get clean; fi
  else
    log "apt-get not present"
  fi
fi

if [ "$YUM_CLEAN" -eq 1 ]; then
  if command -v yum >/dev/null 2>&1; then
    log "Running yum clean all"
    if [ "$SIMULATE" -eq 0 ]; then yum clean all; fi
  else
    log "yum not present"
  fi
fi

# journalctl vacuum
if [ -n "$JOURNAL_VACUUM" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    log "Vacuuming journalctl older than $JOURNAL_VACUUM"
    if [ "$SIMULATE" -eq 0 ]; then
      journalctl --vacuum-time="$JOURNAL_VACUUM" || true
    fi
  else
    log "journalctl not present"
  fi
fi

# docker prune
if [ "$DOCKER_PRUNE" -eq 1 ]; then
  if command -v docker >/dev/null 2>&1; then
    log "Running docker system prune -af"
    if [ "$SIMULATE" -eq 0 ]; then docker system prune -af || true; fi
  else
    log "docker not present"
  fi
fi

# report disk usage after
DF_AFTER="$(df -h / | sed -n '2p')"
log "Disk usage after: $DF_AFTER"

if [ "$DELETED_ANY" -eq 1 ]; then
  log "Cleanup removed some files"
  exit 0
else
  log "Cleanup did not remove files"
  exit 2
fi

#--------------------------------------------------------------------------#
# Notes & usage
# Safety: Default targets /tmp and /var/tmp. Use --paths to specify other directories; the script only deletes regular files older than X days.
# Simulate mode: Use --simulate to inspect what will be removed before actual deletion.
# Package caches: Use --apt-clean or --yum-clean to clear package caches.
# Journalctl: --journal-vacuum 7d will delete journal entries older than 7 days.
# Docker: --docker-prune prunes images/containers/networks/volumes — use with care.
# Automation: Combine with cron or a systemd timer.

# Crontab example (cleanup every Sunday at 03:00):
# >> 0 3 * * 0 /usr/local/bin/cleanup.sh --paths "/tmp,/var/tmp,/var/log/myapp/cache" --older-than 14 --journal-vacuum 14d --apt-clean --simulate --log /var/log/cleanup.log

# (First run with --simulate then remove --simulate once happy.)

# systemd timer (recommended for modern Linux)
# Example backup.service and backup.timer (place in /etc/systemd/system/).

# /etc/systemd/system/backup.service

# [Unit]
# Description=Run backup job

# [Service]
# Type=oneshot
# ExecStart=/usr/local/bin/backup.sh --source /var/www --dest /backups/www --name www --snapshots 14 --compress --log /var/log/backup-www.log


# /etc/systemd/system/backup.timer

# [Unit]
# Description=Daily backup timer

# [Timer]
# OnCalendar=*-*-* 02:30:00
# Persistent=true

# [Install]
# WantedBy=timers.target
# # To use:
# Enable:
# sudo systemctl daemon-reload
# sudo systemctl enable --now backup.timer