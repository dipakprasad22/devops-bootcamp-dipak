#!/bin/bash
# Script: system_monitor_alert.sh
# Description: Monitors CPU/Memory usage and sends email alerts when limits exceeded

# Configuration variables
CPU_THRESHOLD=80.0
MEM_THRESHOLD=80.0
EMAIL_TO="admin@example.com"
EMAIL_FROM="system-monitor@$(hostname)"
# shellcheck disable=SC2034
SMTP_SERVER="localhost"
LOG_FILE="/tmp/system_monitor.log"
ALERT_COOLDOWN=300  # 5 minutes cooldown between alerts
COOLDOWN_FILE="/tmp/monitor_cooldown"

# Print usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -c CPU_LIMIT     Set CPU threshold (default: 80.0)"
    echo "  -m MEM_LIMIT     Set memory threshold (default: 80.0)"
    echo "  -e EMAIL         Set alert email address"
    echo "  -h               Show this help"
    exit 1
}

# Parse command line arguments
while getopts "c:m:e:h" opt; do
    case $opt in
        c) CPU_THRESHOLD=$OPTARG ;;
        m) MEM_THRESHOLD=$OPTARG ;;
        e) EMAIL_TO=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Enhanced function to get system metrics
print_time_cpu_mem() {
    local time_now cpu_usage mem_usage
    time_now=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Get CPU usage (works on most Linux systems)
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | sed 's/%us,//' | sed 's/%sy,//')
    
    # Alternative CPU method if above fails
    if [ -z "$cpu_usage" ] || [ "$cpu_usage" = "0" ]; then
        cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}')
    fi
    
    # Get memory usage
    mem_usage=$(free -m | awk '/Mem:/ { printf "%.2f", $3/$2 * 100.0 }')
    
    echo "$time_now:CPU:${cpu_usage}%:MEM:${mem_usage}%"
}

# Check if we're in alert cooldown period
check_cooldown() {
    if [ -f "$COOLDOWN_FILE" ]; then
        local last_alert
        last_alert=$(cat "$COOLDOWN_FILE")
        local current_time
        current_time=$(date +%s)
        local time_diff
        time_diff=$((current_time - last_alert))
        
        if [ $time_diff -lt $ALERT_COOLDOWN ]; then
            return 1  # Still in cooldown
        fi
    fi
    return 0  # Not in cooldown
}

# Update cooldown timestamp
update_cooldown() {
    date +%s > "$COOLDOWN_FILE"
}

# Send email alert
send_email_alert() {
    local subject="$1"
    local body="$2"
    local hostname
    hostname=$(hostname)
    
    # Create email content
    local email_content
    email_content="Subject: $subject
From: $EMAIL_FROM
To: $EMAIL_TO
Date: $(date)

$body

---
System: $hostname
Monitoring Script: $0
Time: $(date)
"

    # Try different methods to send email
    if command -v mailx >/dev/null 2>&1; then
        echo "$email_content" | mailx -s "$subject" "$EMAIL_TO"
    elif command -v mail >/dev/null 2>&1; then
        echo "$email_content" | mail -s "$subject" "$EMAIL_TO"
    elif command -v sendmail >/dev/null 2>&1; then
        echo "$email_content" | sendmail "$EMAIL_TO"
    else
        echo "ERROR: No email command found (mailx, mail, or sendmail)" | tee -a "$LOG_FILE"
        return 1
    fi
    
    echo "$(date): Email alert sent to $EMAIL_TO" | tee -a "$LOG_FILE"
}

# Check if values exceed thresholds and send alerts
check_and_alert() {
    local cpu_val="$1"
    local mem_val="$2"
    local alert_needed=false
    local alert_message=""
    
    # Remove % symbols and convert to numbers for comparison
    # shellcheck disable=SC2001
    cpu_num=$(echo "$cpu_val" | sed 's/%//')
    # shellcheck disable=SC2001
    mem_num=$(echo "$mem_val" | sed 's/%//')
    
    # Check CPU threshold
    if (( $(echo "$cpu_num > $CPU_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        alert_needed=true
        alert_message="⚠️ HIGH CPU USAGE DETECTED ⚠️\n\nCPU Usage: $cpu_val (Threshold: $CPU_THRESHOLD%)\n"
    fi
    
    # Check memory threshold  
    if (( $(echo "$mem_num > $MEM_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        alert_needed=true
        alert_message="${alert_message}⚠️ HIGH MEMORY USAGE DETECTED ⚠️\n\nMemory Usage: $mem_val (Threshold: $MEM_THRESHOLD%)\n"
    fi
    
    # Send alert if needed and not in cooldown
    if [ "$alert_needed" = true ]; then
        if check_cooldown; then
            local subject
            subject="ALERT: High Resource Usage on $(hostname)"
            send_email_alert "$subject" "$alert_message"
            update_cooldown
        else
            echo "$(date): Alert suppressed - in cooldown period" | tee -a "$LOG_FILE"
        fi
    fi
}

# Main monitoring function
monitor_resources_with_alerts() {
    echo "Starting resource monitoring with email alerts..."
    echo "CPU Threshold: $CPU_THRESHOLD% | Memory Threshold: $MEM_THRESHOLD%"
    echo "Alert Email: $EMAIL_TO"
    echo "Log File: $LOG_FILE"
    echo "---"
    
    # Create/clear log file
    echo "$(date): Starting system monitoring" > "$LOG_FILE"
    
    local iteration=1
    
    while true; do
        # Get system metrics
        local metrics
        metrics=$(print_time_cpu_mem)
        echo "[$iteration] $metrics"
        echo "[$iteration] $metrics" >> "$LOG_FILE"
        
        # Extract CPU and memory values
        local cpu_usage
        cpu_usage=$(echo "$metrics" | cut -d':' -f3)
        local mem_usage
        mem_usage=$(echo "$metrics" | cut -d':' -f4)
        
        # Check thresholds and send alerts if needed
        check_and_alert "$cpu_usage" "$mem_usage"
        
        iteration=$((iteration + 1))
        sleep 5
    done
}

# Continuous monitoring function (runs indefinitely)
monitor_continuous() {
    echo "Starting continuous monitoring (Ctrl+C to stop)..."
    monitor_resources_with_alerts
}

# One-time check function
monitor_once() {
    echo "Performing one-time system check..."
    local metrics
    metrics=$(print_time_cpu_mem)
    echo "$metrics"
    
    local cpu_usage
    cpu_usage=$(echo "$metrics" | cut -d':' -f3)
    local mem_usage
    mem_usage=$(echo "$metrics" | cut -d':' -f4)
    
    check_and_alert "$cpu_usage" "$mem_usage"
}

# Check if required tools are available
check_dependencies() {
    local missing_tools=""
    
    if ! command -v bc >/dev/null 2>&1; then
        missing_tools="$missing_tools bc"
    fi
    
    if ! command -v mailx >/dev/null 2>&1 && ! command -v mail >/dev/null 2>&1 && ! command -v sendmail >/dev/null 2>&1; then
        echo "WARNING: No email command found. Install mailx, mail, or sendmail for email functionality."
    fi
    
    if [ -n "$missing_tools" ]; then
        echo "ERROR: Missing required tools:$missing_tools"
        echo "Please install them before running this script."
        exit 1
    fi
}

# Main execution
main() {
    check_dependencies
    
    echo "=== System Resource Monitor with Email Alerts ==="
    echo "1. Run once and exit: $0 once"
    echo "2. Continuous monitoring: $0 (default)"
    echo ""
    
    if [ "$1" = "once" ]; then
        monitor_once
    else
        monitor_continuous
    fi
}

# Handle script termination gracefully
cleanup() {
    echo ""
    echo "Monitoring stopped. Log file: $LOG_FILE"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"