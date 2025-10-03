#!/usr/bin/env bash
# sysinfo.sh - Comprehensive system information script
# Usage: ./sysinfo.sh [--json|-j] [--output FILE|-o FILE] [--sections sec1,sec2,...] [--all] [--help]
# AUTHOR: Dipak Prasad

set -u                                      # Treat unset variables as an error
TMPDIR="$(mktemp -d /tmp/sysinfo.XXXXXX)"   # temp dir for intermediate files
JSON=0                                      # output JSON if 1, else plain text
OUTFILE=""                                  # output file, else stdout
SECTIONS=""                                 # comma-separated list of sections to run
ALL=0                                       # if 1, run all sections
SCRIPT_NAME="$(basename "$0")"              # script name for help
# Cleanup temp dir on exit
cleanup() {
    rm -rf "$TMPDIR"
}
cleanup
trap cleanup EXIT

has() {
    command -v "$1" >/dev/null 2>&1
}

# Helper to write a section's output to a file
write_section() {
    local name="$1"; shift
    local file="$TMPDIR/$name.txt"
    {
        printf "### %s\n\n" "$name"
        "$@"
    } >"$file" 2>&1 || true
}

# --- Section functions ---
section_host_info() {
    echo "Hostname: $(hostname -f 2>/dev/null || hostname)"
    if has hostnamectl; then hostnamectl; else uname -n; fi
    echo
}
section_host_info

section_os_info() {
    if has lsb_release; then
        lsb_release -a 2>/dev/null || true
    else
        if [ -f /etc/os-release ]; then
            sed -n '1,200p' /etc/os-release
        else
            uname -srm
        fi
    fi
    echo
}
section_os_info

section_kernel_uptime() {
    echo "Kernel: $(uname -srmo)"
    if [ -r /proc/uptime ]; then
        awk '{print "Uptime (seconds): "$1; print "Idle (seconds): "$2}' /proc/uptime
        echo "Uptime human: $(uptime -p 2>/dev/null || uptime)"
    else
        uptime
    fi
    echo
}
section_kernel_uptime

section_users() {
    echo "Current user: $(whoami)"
    echo "Logged in users (who):"
    who || true
    echo
    echo "Last logins:"
    last -n 5 2>/dev/null || true
    echo
}
section_users

section_cpu() {
    if [ -r /proc/cpuinfo ]; then
        awk -F: '/model name|cpu cores|vendor_id|cpu MHz/ {print $1": "$2}' /proc/cpuinfo | uniq -c | sed 's/^ *//'
    else
        lscpu 2>/dev/null || true
    fi
    echo
}
section_cpu

section_memory() {
    if has free; then
        free -h
    elif [ -r /proc/meminfo ]; then
        awk '/MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree/ {print}' /proc/meminfo
    fi
    echo
}
section_memory

section_disks() {
    echo "Block devices:"
    if has lsblk; then
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,UUID -f
    else
        fdisk -l 2>/dev/null || true
    fi
    echo
    echo "Filesystem usage (df -h):"
    df -hT --exclude-type=tmpfs --exclude-type=devtmpfs 2>/dev/null || df -h 2>/dev/null || true
    echo
}
section_disks

section_mounts() {
    echo "Mounts:"
    mount | sed -n '1,200p' || true
    echo
}
section_mounts

section_network() {
    echo "IP addresses / interfaces:"
    if has ip; then
        ip -brief addr show
    else
        ifconfig -a 2>/dev/null || true
    fi
    echo
    echo "Routing table:"
    if has ip; then ip route show; else route -n 2>/dev/null || true; fi
    echo
    echo "Open network ports (listening):"
    if has ss; then ss -tulpen 2>/dev/null || true
    elif has netstat; then netstat -tulpen 2>/dev/null || true
    fi
    echo
    echo "DNS resolvers:"
    if [ -f /etc/resolv.conf ]; then
        sed -n '1,200p' /etc/resolv.conf
    fi
    echo
}
section_network

section_services() {
    if has systemctl; then
        echo "Systemd: unit summary"
        systemctl list-units --type=service --state=running --no-pager 2>/dev/null | sed -n '1,200p'
    elif has service; then
        echo "SysV services (service --status-all):"
        service --status-all 2>/dev/null | sed -n '1,200p'
    fi
    echo
}
section_services

section_processes() {
    echo "Top processes by CPU:"
    ps aux --sort=-%cpu | head -n 10
    echo
    echo "Top processes by memory:"
    ps aux --sort=-%mem | head -n 10
    echo
}
section_processes

section_packages() {
    echo "Package managers detected and recent packages (top lines):"
    if has dpkg-query; then
        echo "-- dpkg (Debian/Ubuntu) --"
        dpkg-query -W -f='${binary:Package}\t${Version}\n' | head -n 20
    fi
    if has rpm; then
        echo "-- rpm (RHEL/Fedora) --"
        rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}\n' | head -n 20
    fi
    if has pacman; then
        echo "-- pacman (Arch) --"
        pacman -Q | head -n 20
    fi
    echo
}
section_packages

section_docker() {
    if has docker; then
        echo "Docker info (docker version / ps):"
        docker version --format '{{json .}}' 2>/dev/null || docker version 2>/dev/null || true
        docker ps -a --format '{{.ID}} {{.Image}} {{.Status}}' 2>/dev/null | sed -n '1,100p'
    elif has podman; then
        echo "Podman info:"
        podman version 2>/dev/null || true
        podman ps -a --format '{{.ID}} {{.Image}} {{.Status}}' 2>/dev/null | sed -n '1,100p'
    fi
    echo
}
section_docker

section_virtualization() {
    echo "Virtualization detection:"
    if has systemd-detect-virt; then
        systemd-detect-virt -v || true
    elif has virt-what; then
        virt-what 2>/dev/null || true
    else
        echo "No virtualization detection tool available (systemd-detect-virt/virt-what missing)."
    fi
    echo
}
section_virtualization

section_security() {
    echo "Firewall (iptables / nft):"
    if has nft; then
        nft list ruleset 2>/dev/null | sed -n '1,200p' || true
    elif has iptables-save; then
        iptables-save -c 2>/dev/null | sed -n '1,200p' || true
    fi
    echo
    echo "SELinux / AppArmor status:"
    if has getenforce; then getenforce || true; fi
    if has aa-status; then aa-status 2>/dev/null || true; fi
    echo
}
section_security

section_hardware() {
    echo "Hardware overview:"
    if has dmidecode && [ "$(id -u)" -eq 0 ]; then
        dmidecode -t system 2>/dev/null | sed -n '1,200p'
    else
        echo "dmidecode not available or not running as root; showing lspci/lsusb/lsblk if present"
    fi
    if has lscpu; then lscpu || true; fi
    if has lspci; then echo; lspci | sed -n '1,100p'; fi
    if has lsusb; then echo; lsusb | sed -n '1,100p'; fi
    if has sensors; then echo; sensors || true; fi
    echo
}
section_hardware

section_kernel_modules() {
    if has lsmod; then
        echo "Loaded kernel modules (lsmod):"
        lsmod | sed -n '1,200p'
    fi
    echo
}
section_kernel_modules

section_logs() {
    echo "Recent system logs (journalctl --no-pager -n 200):"
    if has journalctl; then journalctl --no-pager -n 200 2>/dev/null || true; else
        echo "journalctl not available; tailing /var/log/syslog /var/log/messages if present"
        [ -f /var/log/syslog ] && tail -n 200 /var/log/syslog || true
        [ -f /var/log/messages ] && tail -n 200 /var/log/messages || true
    fi
    echo
}
section_logs

section_custom_checks() {
    echo "Security quick checks:"
    echo "- World-writable files in /tmp (top 20):"
    find /tmp -xdev -type f -perm -0002 -print 2>/dev/null | head -n 20 || true
    echo
    echo "- SUID/SGID files (top 50):"
    find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -print 2>/dev/null | head -n 50 || true
    echo
}
section_custom_checks

# --- Dispatcher: map names to functions ---
run_section() {
    local name="$1"
    case "$name" in
        host) write_section "Host" section_host_info ;;
        os) write_section "OS" section_os_info ;;
        kernel|uptime) write_section "Kernel & Uptime" section_kernel_uptime ;;
        users) write_section "Users" section_users ;;
        cpu) write_section "CPU" section_cpu ;;
        memory) write_section "Memory" section_memory ;;
        disks) write_section "Disks" section_disks ;;
        mounts) write_section "Mounts" section_mounts ;;
        network) write_section "Network" section_network ;;
        services) write_section "Services" section_services ;;
        processes) write_section "Processes" section_processes ;;
        packages) write_section "Packages" section_packages ;;
        docker) write_section "Container Engines" section_docker ;;
        virt|virtualization) write_section "Virtualization" section_virtualization ;;
        security) write_section "Security" section_security ;;
        hardware) write_section "Hardware" section_hardware ;;
        modules) write_section "Kernel Modules" section_kernel_modules ;;
        logs) write_section "Logs" section_logs ;;
        checks) write_section "Quick Security Checks" section_custom_checks ;;
        all)
            # run all canonical sections
            for s in host os kernel users cpu memory disks mounts network services processes packages docker virt security hardware modules logs checks; do
                run_section "$s"
            done
            ;;
        *)
            echo "Unknown section: $name" >&2
            ;;
    esac
}

print_help() {
    cat <<USAGE
$SCRIPT_NAME - Comprehensive system information script

Usage:
  $SCRIPT_NAME [--json|-j] [--output FILE|-o FILE] [--sections sec1,sec2,...] [--all] [--help]

Options:
  -j, --json         Output JSON (requires python3). By default prints plain text report.
  -o, --output FILE  Write report to FILE (or JSON file when --json). Prints to stdout if omitted.
  --sections LIST    Comma-separated list of sections to run. Valid names: host,os,kernel,users,cpu,memory,disks,mounts,network,services,processes,packages,docker,virt,security,hardware,modules,logs,checks,all
  --all              Run all sections (default if no --sections provided).
  -h, --help         Show this help.

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME --sections host,os,cpu,memory
  $SCRIPT_NAME --json --output sysinfo.json
USAGE
}

# --- Argument parsing ---
while [ $# -gt 0 ]; do
    case "$1" in
        -j|--json) JSON=1; shift ;;
        -o|--output) OUTFILE="$2"; shift 2 ;;
        --sections) SECTIONS="$2"; shift 2 ;;
        --all) ALL=1; shift ;;
        -h|--help) print_help; exit 0 ;;
        *) echo "Unknown arg: $1"; print_help; exit 2 ;;
    esac
done

# If no sections specified, default to all
if [ -z "$SECTIONS" ] && [ "$ALL" -eq 0 ]; then
    ALL=1
fi

if [ "$ALL" -eq 1 ]; then
    run_section all
else
    IFS=',' read -r -a arr <<< "$SECTIONS"
    for s in "${arr[@]}"; do
        run_section "$s"
    done
fi

# --- Emit output: plain text or JSON ---
if [ "$JSON" -eq 1 ]; then
    if ! has python3; then
        echo "ERROR: --json requested but python3 is not available. Install python3 or omit --json." >&2
        exit 3
    fi
    # Build Python dict mapping section names -> contents
    python3 - <<PY
import json,sys,os
tmp = "${TMPDIR}"
data = {}
for fname in sorted(os.listdir(tmp)):
    key = os.path.splitext(fname)[0]
    with open(os.path.join(tmp,fname),'r',encoding='utf-8',errors='replace') as f:
        data[key] = f.read()
print(json.dumps(data, indent=2, ensure_ascii=False))
PY
else
    # Concatenate files in order (sorted ensures consistent order)
# ...existing code...
find "$TMPDIR" -type f | sort | while read -r f; do
    cat "$f"
    echo -e "\n"
done
# ...existing code...
fi >"${OUTFILE:-/dev/stdout}"

# If OUTFILE was set and user wants to know:
if [ -n "$OUTFILE" ]; then
    echo "Report written to: $OUTFILE"
fi

exit 0
